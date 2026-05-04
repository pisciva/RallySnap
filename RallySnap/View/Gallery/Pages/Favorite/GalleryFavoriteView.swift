import SwiftUI

struct GalleryFavoriteView: View {
    @State private var favoriteClips: [Clip] = []
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
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
                                    onDelete: {
                                        deleteSingleClip(clip)
                                    },
                                    onToast: { message in
                                        displayToast(message: message)
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
        .onAppear {
            refreshFavorites()
        }
        .overlay(alignment: .top) {
            if showToast {
                toastOverlay
            }
        }
    }
    
    private var toastOverlay: some View {
        Text(toastMessage)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(red: 217/255, green: 255/255, blue: 78/255))
            .clipShape(Capsule())
            .shadow(color: Color(red: 217/255, green: 255/255, blue: 78/255).opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.top, 60)
            .padding(.horizontal, 20)
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(100)
            .ignoresSafeArea()
    }
    
    private func displayToast(message: String) {
        toastMessage = message
        withAnimation(.spring()) {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring()) {
                showToast = false
            }
        }
    }
    
    private func refreshFavorites() {
        let allFavorites = dummySessions
            .flatMap { $0.clips }
            .filter { $0.isFavorite }
            .sorted { $0.recordedAt > $1.recordedAt }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            self.favoriteClips = allFavorites
        }
    }
    
    private func deleteSingleClip(_ clip: Clip) {
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
        displayToast(message: "Successfully deleted \(clip.title)")
    }
}
