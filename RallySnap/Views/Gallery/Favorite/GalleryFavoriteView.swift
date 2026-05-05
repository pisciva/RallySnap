import SwiftUI

struct GalleryFavoriteView: View {
    @EnvironmentObject private var viewModel: GalleryViewModel
    @StateObject private var toast = ToastManager()
    
    var favoriteClips: [Clip] {
        viewModel.sessions
            .flatMap { $0.clips }
            .filter { $0.isFavorite }
            .sorted { $0.recordedAt > $1.recordedAt }
    }
    
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
    }
    
    private func deleteFavoriteClip(_ clip: Clip) {
        viewModel.deleteClip(clip)
        toast.show("Successfully deleted \(clip.title)")
    }
}
