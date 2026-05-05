import CoreML
import Vision

class ActionClassifierService {
    private var poseBuffer: [VNHumanBodyPoseObservation] = []
    private var isCapturingClip = false
    private var rollingBuffer: [(pixelBuffer: CVPixelBuffer, time: Date)] = []
    private let maxBufferSeconds: Double = 5.0
    private let model: actionClassifier
    private let predictionWindowSize = 120
    private var frameBuffer: [CVPixelBuffer] = []
    private let confidenceThreshold: Float = 0.80
    
    var onActionDetected: ((String) -> Void)?
    var onClipSaved: ((Clip) -> Void)?
    
    init?() {
        guard let model = try? actionClassifier() else { return nil }
        self.model = model
    }
    
    // Call for every frame
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        rollingBuffer.append((pixelBuffer, Date()))
        let cutoff = Date().addingTimeInterval(-maxBufferSeconds)
        rollingBuffer.removeAll { $0.time < cutoff }

        // Extract pose FIRST
        let request = VNDetectHumanBodyPoseRequest()
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up).perform([request])
        
        guard let pose = request.results?.first else { return } // no person detected, skip
        
        poseBuffer.append(pose)
        if poseBuffer.count > predictionWindowSize { poseBuffer.removeFirst() }
        guard poseBuffer.count == predictionWindowSize else { return }
        
        predict()
    }
    
    private func predict() {
        do {
            let multiArray = try MLMultiArray(shape: [120, 3, 18], dataType: .float32)
            
            let joints: [VNHumanBodyPoseObservation.JointName] = [
                .nose, .leftEye, .rightEye, .leftEar, .rightEar,
                .leftShoulder, .rightShoulder, .leftElbow, .rightElbow,
                .leftWrist, .rightWrist, .leftHip, .rightHip,
                .leftKnee, .rightKnee, .leftAnkle, .rightAnkle, .root
            ]
            
            for (frameIdx, pose) in poseBuffer.enumerated() {
                for (jointIdx, joint) in joints.enumerated() {
                    let point = try? pose.recognizedPoint(joint)
                    let x = point?.location.x ?? 0.0
                    let y = point?.location.y ?? 0.0
                    let confidence = Double(point?.confidence ?? 0)
                    
                    multiArray[[frameIdx, 0, jointIdx] as [NSNumber]] = NSNumber(value: x)
                    multiArray[[frameIdx, 1, jointIdx] as [NSNumber]] = NSNumber(value: y)
                    multiArray[[frameIdx, 2, jointIdx] as [NSNumber]] = NSNumber(value: confidence)
                }
            }
            
            let prediction = try model.prediction(poses: multiArray)
            let label = prediction.label
            let confidence = prediction.labelProbabilities[label] ?? 0
            
            guard label != "idle" else { return }
            
            if Float(confidence) >= confidenceThreshold && !isCapturingClip {
                isCapturingClip = true
                let frames = rollingBuffer.map { $0.pixelBuffer }
                ClipSavingService.shared.saveClip(frames: frames, action: label) { clip in
                    guard let clip = clip else { return }
                    DispatchQueue.main.async {
                        self.onClipSaved?(clip)
                        // Cool down 5 seconds before next clip
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            self.isCapturingClip = false
                        }
                    }
                }
            }
            
        } catch {
            print("Prediction error: \(error)")
        }
    }
    
}
