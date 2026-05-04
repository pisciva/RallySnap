import SwiftUI
import AVKit

struct VideoThumbnailView: View {
    var videoURL: URL? = nil
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        thumbnailContent
            .task {
                await generateThumbnail()
            }
    }
    
    @ViewBuilder
    private var thumbnailContent: some View {
        if let img = thumbnail {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 0.2))
        }
    }
    
    private func generateThumbnail() async {
        guard let url = videoURL ?? Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4") else { return }
        
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let (cgImage, _) = try await generator.image(at: time)
            let image = UIImage(cgImage: cgImage)
            
            await MainActor.run {
                self.thumbnail = image
            }
        } catch {
            print("Thumbnail error: \(error.localizedDescription)")
        }
    }
}
