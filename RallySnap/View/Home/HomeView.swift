import SwiftUI

struct HomeView: View {
    @State private var showGuidance = false
    @ObservedObject private var camera = CameraManager.shared

    /// All clips across the current session + dummy data, newest first.
    private var recentClips: [Clip] {
        var all: [Clip] = camera.currentSession.clips
        all.append(contentsOf: dummySessions.flatMap { $0.clips })
        return all.sorted { $0.recordedAt > $1.recordedAt }
    }

    var body: some View {

        ZStack{
            Color.black.ignoresSafeArea()
            ScrollView(showsIndicators: false){

                VStack(alignment: .leading){
                    Text("Ready for a match?").foregroundStyle(.white)                               .font(.system(size: 20, weight: .bold))

                    //MARK: Guidance Card
                    Button {
                        showGuidance = true
                    } label: {
                        VStack(spacing:0){
                            Image("asset_homescreen_1")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .frame(height: 160, alignment: .bottom)
                                .clipped()
                            HStack{
                                Text("Click For Guidance")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.white)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white)
                            }.padding()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 26)
                    .padding(.bottom, 32)

                VStack(spacing: 16){

                    HStack{
                        Text("Recently Added").font(.system(size: 20, weight: .regular)).foregroundStyle(.white)
                        Spacer()
                        Text("View All").font(.system(size: 14, weight: .regular)).foregroundStyle(Color(red: 0.85, green: 1.0, blue: 0.31))
                    }.padding(.horizontal, 24)

                    if recentClips.isEmpty {
                        Text("No clips yet — open camera and start playing!")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recentClips.prefix(10)) { clip in
                                    RecentClipCard(clip: clip)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
        }

        .fullScreenCover(isPresented: $showGuidance) {
            GuidanceView()
        }
    }
}

// MARK: - Recent Clip Card

private struct RecentClipCard: View {
    let clip: Clip

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VideoThumbnailView(videoURL: clip.videoURL)
                .frame(width: 160, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(clip.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(formattedDate(clip.recordedAt))
                .font(.system(size: 12))
                .foregroundStyle(.gray)
        }
        .frame(width: 160)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
}
