import SwiftUI

struct SessionCardView: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 12) {
            infoSection
            Spacer()
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
            .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image(systemName: "video.fill")
                    .font(.system(size: 12))
                Text("\(session.clips.count) clips")
                    .font(.system(size: 12))
            }
            .foregroundColor(.gray)
            
            HStack(spacing: 6) {
                let hasAuto = session.clips.contains { $0.mode == .auto }
                let hasManual = session.clips.contains { $0.mode == .manual }
                
                if hasAuto {
                    modeIcon(systemName: "figure.tennis")
                }
                
                if hasManual {
                    modeIcon(systemName: "applewatch")
                }
            }
            .padding(.top, 4)
        }
    }
    
    private var videoStackSection: some View {
        ZStack(alignment: .trailing) {
            let maxClips = min(session.clips.count, 6)
            
            ForEach(0..<maxClips, id: \.self) { index in
                let scale = 1.0 - (CGFloat(index) * 0.08)
                let opacity = 1.0 - (Double(index) * 0.18)
                let xOffset = -CGFloat(maxClips - 1 - index) * 5
                
                VideoThumbnailView()
                    .frame(width: 120 * scale, height: 80 * scale)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    .opacity(opacity)
                    .offset(x: xOffset)
                    .zIndex(Double(maxClips - index))
            }
        }
        .frame(width: 190, height: 80, alignment: .trailing)
    }
    
    private func modeIcon(systemName: String) -> some View {
        Circle()
            .fill(Color(red: 217/255, green: 1.0, blue: 78/255))
            .frame(width: 24, height: 24)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            )
    }
}
