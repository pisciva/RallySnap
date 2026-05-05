import Foundation
import AVFoundation
import Combine
import SwiftUI

extension Notification.Name {
    static let cameraNeedsOrientationUpdate = Notification.Name("cameraNeedsOrientationUpdate")
}

class CameraManager: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var session = AVCaptureSession()
    @Published var permissionDenied = false
    @Published var isRecording = false
    @Published var currentZoom: CGFloat = 1.0
    @Published var isFrontCamera = false
    @Published var recordingDuration: TimeInterval = 0
    private var recordingTimer: Timer?
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let movieFileOutput = AVCaptureMovieFileOutput() // The new output
    private var isConfigured = false
    private var neutralZoomFactor: CGFloat = 1.0
    
    static let shared = CameraManager()
    
    private override init() {
        super.init()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession()
                    } else {
                        self.permissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.permissionDenied = true
            }
        default:
            break
        }
    }
    
    private func getBestCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: position)
        return discoverySession.devices.first
    }
    
    private func updateNeutralZoom(for device: AVCaptureDevice) {
        if device.deviceType == .builtInDualWideCamera || device.deviceType == .builtInTripleCamera {
            neutralZoomFactor = 2.0
        } else {
            neutralZoomFactor = 1.0
        }
    }
    
    private func setupSession() {
        guard !isConfigured else {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .cameraNeedsOrientationUpdate, object: nil)
                }
            }
            return
        }
        
        session.beginConfiguration()
        
        // 1. Setup Video Input
        guard let videoDevice = getBestCamera(for: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            session.commitConfiguration()
            return
        }
        session.addInput(videoInput)
        videoDeviceInput = videoInput
        
        updateNeutralZoom(for: videoDevice)
        try? videoDevice.lockForConfiguration()
        videoDevice.videoZoomFactor = neutralZoomFactor
        videoDevice.unlockForConfiguration()
        DispatchQueue.main.async { self.currentZoom = 1.0 }
        
        // 2. Setup Audio Input
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        // 3. Setup Movie File Output
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        }
        
        session.commitConfiguration()
        isConfigured = true
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .cameraNeedsOrientationUpdate, object: nil)
            }
        }
    }
    
    func flipCamera() {
        session.beginConfiguration()
        session.removeInput(videoDeviceInput)
        
        let position: AVCaptureDevice.Position = isFrontCamera ? .back : .front
        
        guard let videoDevice = getBestCamera(for: position),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            session.addInput(videoDeviceInput)
            session.commitConfiguration()
            return
        }
        
        session.addInput(videoInput)
        videoDeviceInput = videoInput
        isFrontCamera.toggle()
        
        updateNeutralZoom(for: videoDevice)
        try? videoDevice.lockForConfiguration()
        
        if isFrontCamera {
            videoDevice.videoZoomFactor = 1.3
        } else {
            videoDevice.videoZoomFactor = neutralZoomFactor
        }
        videoDevice.unlockForConfiguration()
        DispatchQueue.main.async {
            self.currentZoom = 1.0
        }
        
        session.commitConfiguration()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .cameraNeedsOrientationUpdate, object: nil)
        }
    }
    
    // Zoom Translation Engine
    func setZoom(factor: CGFloat) {
        guard let device = videoDeviceInput?.device else { return }
        
        do {
            try device.lockForConfiguration()
            
            let targetAVZoom: CGFloat
                        
            if isFrontCamera {
                if factor == 0.5 {
                    targetAVZoom = 1.0
                } else if factor == 1.0 {
                    targetAVZoom = 1.3
                } else {
                    targetAVZoom = factor * 1.3
                }
            } else {
                targetAVZoom = factor * neutralZoomFactor
            }
            
            let minZoom = device.minAvailableVideoZoomFactor
            let maxZoom = min(device.maxAvailableVideoZoomFactor, 5.0 * neutralZoomFactor)
            
            let clampedFactor = max(minZoom, min(targetAVZoom, maxZoom))
            
            device.ramp(toVideoZoomFactor: clampedFactor, withRate: 4.0)
            device.unlockForConfiguration()
            
            DispatchQueue.main.async {
                self.currentZoom = factor
            }
        } catch {
            print("Failed to lock device for zoom: \(error)")
        }
    }
    
    
    
    
    // MARK: - Recording Logic (NEW)
    func toggleRecording() {
        if movieFileOutput.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard let connection = movieFileOutput.connection(with: .video) else { return }
        
        // Ensure the video saves in the correct orientation based on the device
        if let currentOrientation = getVideoOrientation() {
            connection.videoOrientation = currentOrientation
        }
        
        // Create a temporary file URL to save the match
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "MatchRecording_\(UUID().uuidString).mov"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        // Start writing to disk
        movieFileOutput.startRecording(to: fileURL, recordingDelegate: self)
        
        DispatchQueue.main.async {
            self.isRecording = true
            self.recordingDuration = 0
            self.recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.recordingDuration += 1
            }
        }
    }
    
    private func stopRecording() {
        movieFileOutput.stopRecording()
        DispatchQueue.main.async {
            self.isRecording = false
            self.recordingTimer?.invalidate()
            self.recordingTimer = nil
            // (Optional) We leave the recordingDuration as is so it doesn't instantly snap to 00:00 when stopped, but you could reset it here.
        }
    }
    
    // Helper to get the current orientation safely
    private func getVideoOrientation() -> AVCaptureVideoOrientation? {
        switch UIDevice.current.orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return .landscapeRight
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
            return
        }
        
        // The video saved in the temp folder
        print("Successfully recorded video at: \(outputFileURL.absoluteString)")
        
        //clip logic
    }
}

struct CameraPreviewView: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> CameraPreviewController {
        let controller = CameraPreviewController()
        controller.session = session
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraPreviewController, context: Context) {
        uiViewController.session = session
    }
}

class CameraPreviewController: UIViewController {
    var session: AVCaptureSession? {
        didSet {
            if previewLayer.session !== session {
                previewLayer.session = session
            }
        }
    }
    
    private var previewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCameraOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        updateCameraOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateCameraOrientation()
        })
    }
    
    @objc func updateCameraOrientation() {
        guard let connection = previewLayer.connection else { return }
        guard connection.isVideoOrientationSupported else { return }
        
        // Match gravity
        let targetOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait: targetOrientation = .portrait
        case .portraitUpsideDown: targetOrientation = .portraitUpsideDown
        case .landscapeLeft: targetOrientation = .landscapeRight
        case .landscapeRight: targetOrientation = .landscapeLeft
        default: targetOrientation = .landscapeRight
        }
        
        if connection.videoOrientation != targetOrientation {
            connection.videoOrientation = targetOrientation
        }
    }
    
    @available(iOS, deprecated: 17.0)
    private func videoOrientation(from interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch interfaceOrientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return .landscapeRight
        }
    }
}
