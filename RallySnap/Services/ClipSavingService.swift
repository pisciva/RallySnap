import Foundation
import AVFoundation

class ClipSavingService {
    static let shared = ClipSavingService()
    
    // Save clip from rolling buffer frames
    func saveClip(frames: [CVPixelBuffer], action: String, completion: @escaping (Clip?) -> Void) {
        let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(UUID().uuidString).mp4")
        
        writeFrames(frames, to: outputURL) { success in
            guard success else { completion(nil); return }
            
            let clip = Clip(
                title: action.capitalized,
                recordedAt: Date(),
                duration: Double(frames.count) / 30.0, // assume 30fps
                mode: .auto,
                videoURL: outputURL
            )
            completion(clip)
        }
    }
    
    private func writeFrames(_ frames: [CVPixelBuffer], to url: URL, completion: @escaping (Bool) -> Void) {
        guard let first = frames.first else { completion(false); return }
        
        let width = CVPixelBufferGetWidth(first)
        let height = CVPixelBufferGetHeight(first)
        
        guard let writer = try? AVAssetWriter(outputURL: url, fileType: .mp4) else {
            completion(false); return
        }
        
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        
        writer.add(input)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        var frameCount = 0
        let fps: Int32 = 30
        
        for pixelBuffer in frames {
            let time = CMTime(value: CMTimeValue(frameCount), timescale: fps)
            while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.01) }
            adaptor.append(pixelBuffer, withPresentationTime: time)
            frameCount += 1
        }
        
        input.markAsFinished()
        writer.finishWriting { completion(writer.status == .completed) }
    }
}
