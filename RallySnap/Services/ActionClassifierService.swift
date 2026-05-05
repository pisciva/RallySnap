import CoreML
import Vision
import AVFoundation

class ActionClassifierService {

    private let windowSize = 120
    private let frameSkip = 3
    private let confidenceThreshold: Float = 0.85
    private let clipCooldown: TimeInterval = 3.0
    private let clipLookbackSeconds: Double = 4.0

    // Keep every frame so 30fps playback matches real-time capture speed.
    private let clipFrameKeepEvery = 1

    private let model: actionClassifier
    private var poseWindow: [MLMultiArray] = []

    // Hold COPIED pixel buffers, not the original sample buffer references —
    // holding originals starves AVFoundation's capture buffer pool and
    // freezes frame delivery after a few seconds.
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

    /// Allocate our own pixel buffer and memcpy the source's pixels into it.
    /// This frees the original sample buffer back to the capture pool.
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

        let srcAddr = CVPixelBufferGetBaseAddress(source)
        let dstAddr = CVPixelBufferGetBaseAddress(dst)
        let bytes = CVPixelBufferGetDataSize(source)
        if let s = srcAddr, let d = dstAddr {
            memcpy(d, s, bytes)
        }

        CVPixelBufferUnlockBaseAddress(dst, [])
        CVPixelBufferUnlockBaseAddress(source, .readOnly)

        return dst
    }

    func processFrame(_ sampleBuffer: CMSampleBuffer) {
        frameCount += 1

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Keep a copied frame for clip building every Nth frame.
        if frameCount % clipFrameKeepEvery == 0,
           let copy = deepCopyPixelBuffer(pixelBuffer) {
            let now = Date()
            clipFrames.append((copy, now))
            let cutoff = now.addingTimeInterval(-clipLookbackSeconds - 1)
            clipFrames.removeAll { $0.time < cutoff }
        }

        // Only run Vision+ML every Nth frame.
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
            saveClip(action: label)

        } catch {
            print("AI prediction error: \(error)")
        }
    }

    private func saveClip(action: String) {
        let cutoff = Date().addingTimeInterval(-clipLookbackSeconds)
        let frames = clipFrames
            .filter { $0.time >= cutoff }
            .map { $0.pixelBuffer }

        guard !frames.isEmpty else {
            savingClip = false
            return
        }

        print("AI: 💾 saving clip '\(action)' with \(frames.count) frames")

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
