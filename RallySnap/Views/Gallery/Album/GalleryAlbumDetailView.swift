import SwiftUI

struct GalleryAlbumDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject private var viewModel: GalleryViewModel

    @State private var isSelectionMode = false
    @State private var selectedClipIDs: Set<UUID> = []
    @StateObject private var toast = ToastManager()

    let albumID: UUID

    init(album: Album) {
        self.albumID = album.id
    }

    var album: Album {
        viewModel.albums.first(where: { $0.id == albumID }) ?? Album(title: "", clips: [])
    }

    var selectedClips: [Clip] {
        album.clips.filter { selectedClipIDs.contains($0.id) }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            clipList
            
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
                        viewModel.deleteClipsFromAlbum(ids: selectedClipIDs, albumID: albumID)
                        selectedClipIDs.removeAll()
                        isSelectionMode = false
                    },
                    onAddedToAlbum: { message in toast.show(message) },
                    onFavorite: {
                        viewModel.toggleFavoriteClipsInAlbum(ids: selectedClipIDs, albumID: albumID)
                        selectedClipIDs.removeAll()
                        isSelectionMode = false
                    },
                    onSave: {
                        selectedClipIDs.removeAll()
                        isSelectionMode = false
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .toastOverlay(message: toast.message, isShowing: $toast.isShowing)
        .onChange(of: isSelectionMode) { _, newValue in
            withAnimation { router.isTabBarHidden = newValue }
        }
        .onDisappear {
            router.isTabBarHidden = false
        }
    }

    private var clipList: some View {
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
                                viewModel.deleteClipFromAlbum(clip, albumID: albumID)
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
}
