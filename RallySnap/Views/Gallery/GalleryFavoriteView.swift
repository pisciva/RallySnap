import SwiftUI

struct GalleryFavoriteView: View {
    @State private var favoriteClips: [Clip] = []
    @StateObject private var toast = ToastManager()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Favorites")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    
                    if favoriteClips.isEmpty {
                        Text("No favorite clips yet.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color(white: 0.4))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 60)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(favoriteClips) { clip in
                                ClipCardView(
                                    clip: clip,
                                    onDelete: { deleteFavoriteClip(clip) },
                                    onToast: { message in
                                        toast.show(message)
                                        refreshFavorites()
                                    }
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .toastOverlay(message: toast.message, isShowing: $toast.isShowing)
        .onAppear {
            refreshFavorites()
        }
    }
    
    private func refreshFavorites() {
        let allFavorites = dummySessions
            .flatMap { $0.clips }
            .filter { $0.isFavorite }
            .sorted { $0.recordedAt > $1.recordedAt }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            favoriteClips = allFavorites
        }
    }
    
    private func deleteFavoriteClip(_ clip: Clip) {
        withAnimation(.easeInOut(duration: 0.2)) {
            for index in dummySessions.indices {
                dummySessions[index].clips.removeAll { $0.id == clip.id }
            }
            dummySessions.removeAll { $0.clips.isEmpty }
            
            for index in dummyAlbums.indices {
                dummyAlbums[index].clips.removeAll { $0.id == clip.id }
            }
            
            refreshFavorites()
        }
        toast.show("Successfully deleted \(clip.title)")
    }
}
