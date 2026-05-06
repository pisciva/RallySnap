import CoreML
import Vision
import AVFoundation

class ActionClassifierService {

    private let windowSize = 120
    private let frameSkip = 3
    private let confidenceThreshold: Float = 0.85
    private let clipCooldown: TimeInterval = 3.0

    /// How far back the rolling ring keeps frames for clip extraction.
    /// Watch can request up to this many seconds.
    private let maxLookbackSeconds: Double = 10.0
    private let clipFrameKeepEvery = 1

    private let model: actionClassifier
    private var poseWindow: [MLMultiArray] = []

    private var clipFrames: [(pixelBuffer: CVPixelBuffer, time: Date)] = []
    private var lastClipAt: Date = .distantPast
    private var frameCount = 0
    private var savingClip = false

    var onClipSaved: ((Clip) -> Void)?
    var onPredictionResult: ((String, Float) -> Void)?

    init?() {
        guard let model = try? actionClassifier() else { return nil }
        self.model = model
        for _ in 0..<windowSize {
            let arr = try! MLMultiArray(shape: [1, 3, 18], dataType: .double)
            for i in 0..<arr.count { arr[i] = 0 }
            poseWindow.append(arr)
        }
    }

    private func copyKeypoints(_ source: MLMultiArray) -> MLMultiArray {
        let copy = try! MLMultiArray(shape: [1, 3, 18], dataType: .double)
        for i in 0..<source.count { copy[i] = source[i] }
        return copy
    }

    private func deepCopyPixelBuffer(_ source: CVPixelBuffer) -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(source)
        let height = CVPixelBufferGetHeight(source)
        let format = CVPixelBufferGetPixelFormatType(source)

        var copy: CVPixelBuffer?
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
        ]
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         format, attrs as CFDictionary, &copy)
        guard status == kCVReturnSuccess, let dst = copy else { return nil }

        CVPixelBufferLockBaseAddress(source, .readOnly)
        CVPixelBufferLockBaseAddress(dst, [])

        if let s = CVPixelBufferGetBaseAddress(source),
           let d = CVPixelBufferGetBaseAddress(dst) {
            memcpy(d, s, CVPixelBufferGetDataSize(source))
        }

        CVPixelBufferUnlockBaseAddress(dst, [])
        CVPixelBufferUnlockBaseAddress(source, .readOnly)
        return dst
    }

    func processFrame(_ sampleBuffer: CMSampleBuffer) {
        frameCount += 1

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if frameCount % clipFrameKeepEvery == 0,
           let copy = deepCopyPixelBuffer(pixelBuffer) {
            let now = Date()
            clipFrames.append((copy, now))
            let cutoff = now.addingTimeInterval(-maxLookbackSeconds - 1)
            clipFrames.removeAll { $0.time < cutoff }
        }

        guard frameCount % frameSkip == 0 else { return }

        let request = VNDetectHumanBodyPoseRequest()
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                   orientation: .up).perform([request])

        let frameToAppend: MLMultiArray
        if let pose = request.results?.first,
           let kp = try? pose.keypointsMultiArray() {
            frameToAppend = copyKeypoints(kp)
        } else {
            frameToAppend = copyKeypoints(poseWindow.last!)
        }

        poseWindow.removeFirst()
        poseWindow.append(frameToAppend)

        guard !savingClip else { return }

        let stacked = MLMultiArray(concatenating: poseWindow,
                                   axis: 0,
                                   dataType: .double)
        do {
            let prediction = try model.prediction(poses: stacked)
            let label = prediction.label
            let confidence = Float(prediction.labelProbabilities[label] ?? 0)

            print("AI: \(label) \(Int(confidence * 100))%")

            DispatchQueue.main.async {
                self.onPredictionResult?(label, confidence)
            }

            guard label != "idle",
                  confidence >= confidenceThreshold,
                  Date().timeIntervalSince(lastClipAt) >= clipCooldown else { return }

            lastClipAt = Date()
            savingClip = true
            saveClip(action: label, lookback: 4.0)

        } catch {
            print("AI prediction error: \(error)")
        }
    }

    /// Public manual save — called by the Watch via PhoneConnectivityManager.
    /// Saves the last `lookback` seconds (clamped to maxLookbackSeconds) as a clip.
    func saveManualClip(lookback: Double) {
        let actualLookback = min(max(lookback, 1.0), maxLookbackSeconds)
        guard !savingClip else {
            print("AI: manual clip ignored — already saving")
            return
        }
        savingClip = true
        lastClipAt = Date()
        saveClip(action: "manual", lookback: actualLookback)
    }

    private func saveClip(action: String, lookback: Double) {
        let cutoff = Date().addingTimeInterval(-lookback)
        let frames = clipFrames
            .filter { $0.time >= cutoff }
            .map { $0.pixelBuffer }

        guard !frames.isEmpty else {
            print("AI: ❌ no frames to save")
            savingClip = false
            return
        }

        print("AI: 💾 saving '\(action)' clip — \(frames.count) frames, \(lookback)s lookback")

        ClipSavingService.shared.saveClip(frames: frames, action: action) { clip in
            DispatchQueue.main.async {
                if let clip = clip {
                    print("AI: ✅ clip saved")
                    self.onClipSaved?(clip)
                } else {
                    print("AI: ❌ clip save failed")
                }
                self.savingClip = false
            }
        }
    }
}
