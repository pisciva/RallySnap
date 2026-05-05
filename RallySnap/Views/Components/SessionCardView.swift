import SwiftUI

struct SessionCardView: View {
    let session: Session
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            infoSection
            
            Spacer(minLength: 0)
            
            videoStackSection
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 100)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(session.title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                Text("\(session.dateString), \(session.timeString)")
                    .font(.system(size: 12))
            }
            .foregroundColor(Color(red: 131/255, green: 131/255, blue: 131/255))
            
            HStack(spacing: 4) {
                Image(systemName: "video.fill")
                    .font(.system(size: 12))
                Text("\(session.clips.count) clips")
                    .font(.system(size: 12))
            }
            .foregroundColor(Color(red: 131/255, green: 131/255, blue: 131/255))
            
            HStack(spacing: 6) {
                ForEach(session.modes, id: \.self) { mode in
                    Circle()
                        .fill(Color(red: 217/255, green: 1, blue: 78/255))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: mode == .auto ? "figure.tennis" : "applewatch")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                        )
                }
            }
            .padding(.top, 2)
        }
    }
    
    private var videoStackSection: some View {
        ZStack(alignment: .trailing) {
            let maxClips = min(session.clips.count, 6)
            let baseWidth: CGFloat = 120
            let baseHeight: CGFloat = 80
            let offsetStep: CGFloat = 5
            let scaleStep: CGFloat = 0.08
            
            ForEach(0..<maxClips, id: \.self) { index in
                let scale = 1.0 - CGFloat(index) * scaleStep
                let opacity = 1.0 - Double(index) * 0.18
                
                VideoThumbnailView()
                    .frame(width: baseWidth * scale, height: baseHeight * scale)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    .opacity(opacity)
                    .offset(x: -CGFloat(maxClips - 1 - index) * offsetStep)
                    .zIndex(Double(maxClips - index))
            }
        }
        .frame(width: 190, height: 80, alignment: .trailing)
    }
}
