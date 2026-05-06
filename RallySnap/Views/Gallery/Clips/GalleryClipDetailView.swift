import SwiftUI

struct GalleryClipDetailView: View {
    let dateString: String

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject private var viewModel: GalleryViewModel
    @ObservedObject private var camera = CameraManager.shared

    @State private var isSelectionMode = false
    @State private var selectedClipIDs: Set<UUID> = []
    @StateObject private var toast = ToastManager()

    var sessions: [Session] {
        var all = viewModel.sessions
        if !camera.currentSession.clips.isEmpty {
            all.append(camera.currentSession)
        }
        return all.filter { $0.dateString == dateString }
    }

    var selectedClips: [Clip] {
        sessions.flatMap { $0.clips }.filter { selectedClipIDs.contains($0.id) }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            clipList

            DetailTopBar(
                title: dateString,
                isSelectionMode: $isSelectionMode,
                onBack: { dismiss() },
                onSelectionToggle: { selectedClipIDs.removeAll() }
            )

            if isSelectionMode {
                ClipSelectionBottomBar(
                    isSelectionMode: $isSelectionMode,
                    selectedClipIDs: $selectedClipIDs,
                    selectedClips: selectedClips,
                    onDelete: {
                        viewModel.deleteClips(ids: selectedClipIDs) {
                            if sessions.isEmpty { dismiss() }
                        }
                        selectedClipIDs.removeAll()
                        isSelectionMode = false
                    },
                    onAddedToAlbum: { message in toast.show(message) },
                    onFavorite: {
                        viewModel.toggleFavoriteClips(ids: selectedClipIDs)
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
        .toastOverlay(message: toast.message, isShowing: $toast.isShowing)
        .navigationBarHidden(true)
        .onChange(of: isSelectionMode) { _, newValue in
            withAnimation { router.isTabBarHidden = newValue }
        }
        .onDisappear {
            router.isTabBarHidden = false
        }
    }

    private var clipList: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(sessions) { session in
                    if !session.clips.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(session.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                                .padding(.horizontal, 16)

                            ForEach(session.clips) { clip in
                                SelectableClipRow(
                                    clip: clip,
                                    isSelectionMode: $isSelectionMode,
                                    selectedClipIDs: $selectedClipIDs,
                                    onDelete: {
                                        viewModel.deleteClip(clip) {
                                            if sessions.isEmpty { dismiss() }
                                        }
                                    },
                                    onToast: { message in toast.show(message) }
                                )
                            }
                        }
                    }
                }
            }
            .padding(.top, 80)
            .padding(.bottom, isSelectionMode ? 180 : 120)
        }
    }
}
