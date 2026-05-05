import SwiftUI

struct AlbumDetailView: View {
    @State private var album: Album
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @State var isSelectionMode = false
    @State var selectedClipIDs: Set<UUID> = []
    @StateObject private var toast = ToastManager()
    
    init(album: Album) {
        _album = State(initialValue: album)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            contentSection
            DetailTopBar(
                title: album.title,
                isSelectionMode: $isSelectionMode,
                onBack: { dismiss() },
                onSelectionToggle: { selectedClipIDs.removeAll() },
                showSelectButton: !album.clips.isEmpty
            )
            
            if isSelectionMode {
                ClipSelectionBottomBar(
                    isSelectionMode: $isSelectionMode,
                    selectedClipIDs: $selectedClipIDs,
                    selectedClips: selectedClips,
                    onDelete: {
                        deleteClipsFromAlbum(
                            albumClips: &album.clips,
                            albumID: album.id,
                            selectedClipIDs: &selectedClipIDs,
                            isSelectionMode: &isSelectionMode
                        )
                    },
                    onAddedToAlbum: { message in toast.show(message) },
                    onFavorite: {
                        favoriteClipsInAlbum(
                            albumClips: &album.clips,
                            albumID: album.id,
                            selectedClipIDs: &selectedClipIDs,
                            isSelectionMode: &isSelectionMode
                        )
                    },
                    onSave: {
                        saveSelectedClips(
                            selectedClipIDs: &selectedClipIDs,
                            isSelectionMode: &isSelectionMode
                        )
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .toastOverlay(message: toast.message, isShowing: $toast.isShowing)
        .onChange(of: isSelectionMode) { oldValue, newValue in
            withAnimation {
                router.isTabBarHidden = newValue
            }
        }
        .onDisappear {
            router.isTabBarHidden = false
        }
    }
    
    private var contentSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                if album.clips.isEmpty {
                    Text("No clips in this album yet.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.top, 60)
                } else {
                    ForEach(album.clips) { clip in
                        SelectableClipRow(
                            clip: clip,
                            isSelectionMode: $isSelectionMode,
                            selectedClipIDs: $selectedClipIDs,
                            onDelete: {
                                deleteSingleClipFromAlbum(
                                    clip,
                                    albumClips: &album.clips,
                                    albumID: album.id
                                )
                            },
                            onToast: { message in toast.show(message) }
                        )
                    }
                }
            }
            .padding(.top, 80)
            .padding(.bottom, isSelectionMode ? 180 : 120)
        }
    }
    
    private var selectedClips: [Clip] {
        album.clips.filter { selectedClipIDs.contains($0.id) }
    }
}

extension AlbumDetailView: ClipActionHandler {
    func displayToast(message: String) {
        toast.show(message)
    }
}
