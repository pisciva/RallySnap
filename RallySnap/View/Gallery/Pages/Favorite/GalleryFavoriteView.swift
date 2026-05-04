import SwiftUI

struct GalleryFavoriteView: View {
    // State lokal untuk menyimpan daftar klip favorit
    @State private var favoriteClips: [Clip] = []
    
    // State untuk Toast Notification yang sudah disempurnakan (Statis Pinned)
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
                                        // Refresh otomatis jika status favorit diubah
                                        refreshFavorites()
                                    }
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(.bottom, 120) // Ruang ekstra agar tidak menabrak bottom tab bar
            }
        }
        // Refresh data setiap kali halaman ini dibuka
        .onAppear {
            refreshFavorites()
        }
        // OVERLAY TOAST STATIS DI SINI
        .overlay(alignment: .top) {
            if showToast {
                toastOverlay
            }
        }
    }
    
    // MARK: - Toast Overlay
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
    
    // MARK: - Logic Functions
    
    private func refreshFavorites() {
        // Tarik semua klip dari dummySessions, saring yang difavoritkan,
        // lalu urutkan berdasarkan yang paling baru direkam
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
            // Hapus dari database dummy pusat
            for index in dummySessions.indices {
                dummySessions[index].clips.removeAll { $0.id == clip.id }
            }
            // Bersihkan session kosong jika ada
            dummySessions.removeAll { $0.clips.isEmpty }
            
            // Hapus dari album jika klip ini juga ada di album
            for index in dummyAlbums.indices {
                dummyAlbums[index].clips.removeAll { $0.id == clip.id }
            }
            
            // Update UI lokal
            refreshFavorites()
        }
        displayToast(message: "Successfully deleted \(clip.title)")
    }
}
