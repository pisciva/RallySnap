import SwiftUI

struct SessionCardView: View {
    let session: Session
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            infoSection
            modeBadgesSection
            videoStackSection
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 80)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(session.title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                Text("\(session.date), \(session.time)")
                    .font(.system(size: 12))
            }
            .foregroundColor(Color(red: 131/255, green: 131/255, blue: 131/255))
            
            HStack(spacing: 4) {
                Image(systemName: "video.fill")
                    .font(.system(size: 12))
                Text("\(session.clipCount) clips")
                    .font(.system(size: 12))
            }
            .foregroundColor(Color(red: 131/255, green: 131/255, blue: 131/255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var modeBadgesSection: some View {
        VStack(spacing: 5) {
            ForEach(session.modes, id: \.self) { mode in
                Circle()
                    .fill(Color(red: 217/255, green: 1, blue: 78/255))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(mode)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    )
            }
        }
        .frame(width: 28, alignment: .center)
    }
    
    private var videoStackSection: some View {
        ZStack(alignment: .leading) {
            let maxClips = min(session.clipCount, 6)
            let baseWidth: CGFloat = 80
            let baseHeight: CGFloat = 55
            let offsetStep: CGFloat = 10
            let scaleStep: CGFloat = 0.08
            
            ForEach(0..<maxClips, id: \.self) { index in
                let scale = 1.0 - CGFloat(index) * scaleStep
                let opacity = 1.0 - Double(index) * 0.18
                
                VideoThumbnailView()
                    .frame(width: baseWidth * scale, height: baseHeight * scale)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
                    .opacity(opacity)
                    .offset(x: CGFloat(index) * offsetStep)
                    .zIndex(Double(maxClips - index))
            }
        }
        .frame(width: 90, height: 55, alignment: .leading)
        .clipped()
    }
}
