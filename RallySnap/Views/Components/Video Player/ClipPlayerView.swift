import SwiftUI
import AVFoundation

struct ClipPlayerView: View {
    // source disimpan sebagai let, tidak pernah di-override
    let source: PlayerSource

    @EnvironmentObject private var galleryVM: GalleryViewModel
    @Environment(\.presentationMode) var presentationMode

    @StateObject private var vm: PlayerViewModel
    @StateObject private var toast = ToastManager()

    @State private var isLandscape = false
    @State private var isFavorite: Bool
    @State private var showAddToAlbumSheet = false
    @State private var showNewAlbumAlert = false
    @State private var showDeleteConfirmation = false
    @State private var newAlbumName = ""

    init(clip: Clip, source: PlayerSource) {
        self.source = source
        self._isFavorite = State(initialValue: clip.isFavorite)
        self._vm = StateObject(wrappedValue: PlayerViewModel(clip: clip))
    }

    // isFavorite mengikuti currentClip yang aktif di vm
    private var currentClip: Clip { vm.currentClip }

    private var relatedClips: [Clip] {
        vm.relatedClips(for: source, in: galleryVM)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .toastOverlay(message: toast.message, isShowing: $toast.isShowing)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: isLandscape ? .all : [])
        .sheet(isPresented: $showAddToAlbumSheet) {
            AddToAlbumSheetView(
                clip: currentClip,
                isPresented: $showAddToAlbumSheet,
                showNewAlbumAlert: $showNewAlbumAlert,
                onToast: { toast.show($0) }
            )
            .environmentObject(galleryVM)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert("New Album", isPresented: $showNewAlbumAlert) {
            TextField("Album Name", text: $newAlbumName)
            Button("Cancel", role: .cancel) { newAlbumName = "" }
            Button("Create") { createNewAlbumAndAdd() }
        }
        .alert("Delete Clip", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteClip() }
        } message: {
            Text("Are you sure you want to delete \"\(currentClip.title)\"? This action cannot be undone.")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isLandscape = UIDevice.current.orientation.isLandscape
            }
        }
        // sync isFavorite setiap kali currentClip berganti
        .onChange(of: vm.currentClip.id) { _ in
            isFavorite = vm.currentClip.isFavorite
        }
        .onAppear { UIDevice.current.beginGeneratingDeviceOrientationNotifications() }
        .onDisappear {
            vm.pause()
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }

    // MARK: - Layouts

    private var portraitLayout: some View {
        VStack(spacing: 0) {
            ZStack {
                VideoSurfaceView(player: vm.player)
                    .background(Color.black)
                    .aspectRatio(16/9, contentMode: .fit)
                playerOverlay
            }
            .frame(maxWidth: .infinity)

            RelatedClipsListView(
                vm: vm,
                source: source,
                clips: relatedClips,
                sourceLabel: vm.sourceLabel(for: source)
            )
        }
    }

    private var landscapeLayout: some View {
        ZStack {
            VideoSurfaceView(player: vm.player)
                .background(Color.black)
                .ignoresSafeArea()
            playerOverlay
        }
    }

    private var playerOverlay: some View {
        PlayerOverlayView(
            isLandscape: isLandscape,
            isFavorite: isFavorite,
            vm: vm,
            onDismiss: { presentationMode.wrappedValue.dismiss() },
            onToggleFavorite: toggleFavorite,
            onAddToAlbum: { showAddToAlbumSheet = true },
            onSave: { toast.show("Saved to device successfully") },
            onDelete: { showDeleteConfirmation = true }
        )
    }

    // MARK: - Actions

    private func toggleFavorite() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isFavorite.toggle()
        }
        galleryVM.toggleFavoriteClips(ids: [currentClip.id])
        toast.show(isFavorite ? "Added to favorites" : "Removed from favorites")
    }

    private func deleteClip() {
        galleryVM.deleteClip(currentClip)
        toast.show("Clip deleted successfully")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func createNewAlbumAndAdd() {
        guard !newAlbumName.isEmpty else { return }
        let name = newAlbumName
        galleryVM.albums.append(Album(title: name, clips: [currentClip]))
        newAlbumName = ""
        showAddToAlbumSheet = false
        toast.show("Added to new album \"\(name)\"")
    }
}
