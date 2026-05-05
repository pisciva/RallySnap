import SwiftUI
import AVFoundation
import AVKit
import Combine

// -- konteks dari mana player dibuka, menentukan list klip di bawah
enum PlayerSource {
    case album(Album)
    case session(Session)
    case favorites
    case none
}

// MARK: - main view
struct ClipPlayerView: View {

    let clip: Clip
    let source: PlayerSource

    @StateObject private var vm: PlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var toast = ToastManager()

    @State private var isLandscape = false

    // -- state untuk sheet & alert (sama persis dengan ClipSelectionBottomBar)
    @State private var showAddToAlbumSheet = false
    @State private var showNewAlbumAlert = false
    @State private var showDeleteConfirmation = false
    @State private var newAlbumName = ""

    init(clip: Clip, source: PlayerSource = .none) {
        self.clip = clip
        self.source = source
        _vm = StateObject(wrappedValue: PlayerViewModel(clip: clip))
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
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(edges: isLandscape ? .all : [])
        // -- sheet add to album (logic sama dengan ClipSelectionBottomBar)
        .sheet(isPresented: $showAddToAlbumSheet) {
            addToAlbumSheetContent
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        // -- alert buat album baru
        .alert("New Album", isPresented: $showNewAlbumAlert) {
            TextField("Album Name", text: $newAlbumName)
            Button("Cancel", role: .cancel) { newAlbumName = "" }
            Button("Create") { createNewAlbumAndAdd() }
        }
        // -- konfirmasi delete
        .alert("Delete Clip", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                vm.deleteClip()
                toast.show("Clip deleted successfully")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(clip.title)\"? This action cannot be undone.")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isLandscape = UIDevice.current.orientation.isLandscape
            }
        }
        .onAppear { UIDevice.current.beginGeneratingDeviceOrientationNotifications() }
        .onDisappear {
            vm.pause()
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }

    // MARK: - layouts

    // -- portrait: video atas, list klip bawah
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            ZStack {
                videoSurface
                    .aspectRatio(16/9, contentMode: .fit)
                playerOverlay
            }
            .frame(maxWidth: .infinity)

            otherClipsList
        }
    }

    // -- landscape: video penuh layar
    private var landscapeLayout: some View {
        ZStack {
            videoSurface.ignoresSafeArea()
            playerOverlay
        }
    }

    // MARK: - video surface

    private var videoSurface: some View {
        VideoSurfaceView(player: vm.player)
            .background(Color.black)
    }

    // MARK: - player overlay (semua kontrol di atas video)

    private var playerOverlay: some View {
        ZStack {
            // -- gradient atas & bawah agar teks terbaca
            VStack {
                LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 100)
                Spacer()
                LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 160)
            }

            VStack {
                topBar
                Spacer()
                VStack(spacing: 6) {
                    timelineBar
                    bottomControls
                }
                .padding(.horizontal, 16)
                .padding(.bottom, isLandscape ? 20 : 12)
            }

            centerPlayButton
        }
    }

    // MARK: - top bar

    private var topBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            Spacer()

            Text(clip.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            speedMenu
        }
        .padding(.horizontal, 16)
        .padding(.top, isLandscape ? 12 : 50)
    }

    // -- dropdown pilihan kecepatan
    private var speedMenu: some View {
        Menu {
            ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { speed in
                Button(action: { vm.setSpeed(Float(speed)) }) {
                    HStack {
                        Text("\(speed == 1.0 ? "1" : String(format: "%.1f", speed))x")
                        if vm.playbackSpeed == Float(speed) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text("\(vm.playbackSpeed == 1.0 ? "1" : String(format: "%.1f", vm.playbackSpeed))x")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 48, height: 32)
                .background(Color(red: 217/255, green: 255/255, blue: 78/255))
                .clipShape(Capsule())
        }
    }

    // MARK: - center play button

    private var centerPlayButton: some View {
        Button(action: { vm.togglePlayPause() }) {
            Image(systemName: vm.isFinished
                  ? "arrow.counterclockwise"
                  : (vm.isPlaying ? "pause.fill" : "play.fill"))
                .font(.system(size: 36))
                .foregroundColor(.white)
                .frame(width: 72, height: 72)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .opacity(vm.isPlaying && !vm.showControls ? 0 : 1)
    }

    // MARK: - timeline

    private var timelineBar: some View {
        VStack(spacing: 4) {
            Slider(value: $vm.progress, in: 0...1, onEditingChanged: { editing in
                vm.isScrubbing = editing
                if !editing { vm.seekToProgress() }
            })
            .accentColor(Color(red: 217/255, green: 255/255, blue: 78/255))

            HStack {
                Text(vm.currentTimeString)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text(vm.durationString)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    // MARK: - bottom action buttons

    private var bottomControls: some View {
        HStack(spacing: 0) {
            // -- favorite / unfavorite
            actionButton(
                icon: vm.isFavorite ? "heart.fill" : "heart",
                color: vm.isFavorite ? .red : .white,
                label: vm.isFavorite ? "Unfavorite" : "Favorite"
            ) {
                vm.toggleFavorite()
                toast.show(vm.isFavorite ? "Added to favorites" : "Removed from favorites")
            }

            // -- add to album (buka sheet sama persis dengan ClipSelectionBottomBar)
            actionButton(icon: "folder.badge.plus", color: .white, label: "Add to Album") {
                showAddToAlbumSheet = true
            }

            // -- save to device
            actionButton(icon: "arrow.down.to.line", color: .white, label: "Save") {
                toast.show("Saved to device successfully")
            }

            // -- delete (buka konfirmasi sama persis dengan ClipSelectionBottomBar)
            actionButton(icon: "trash", color: .red, label: "Delete") {
                showDeleteConfirmation = true
            }
        }
    }

    private func actionButton(icon: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - related clips list (portrait only)

    private var otherClipsList: some View {
        let clips = relatedClips()

        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if clips.isEmpty {
                    Text("No other clips available.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 32)
                } else {
                    // -- header section label
                    Text(sourceLabel())
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 8)

                    ForEach(clips) { other in
                        NavigationLink(destination: ClipPlayerView(clip: other, source: source)) {
                            relatedClipRow(other)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Divider()
                            .background(Color.white.opacity(0.07))
                            .padding(.leading, 128)
                    }
                }
            }
        }
        .background(Color(white: 0.07))
    }

    // -- satu baris klip di list bawah
    private func relatedClipRow(_ other: Clip) -> some View {
        let isActive = other.id == clip.id
        let accent = Color(red: 217/255, green: 255/255, blue: 78/255)

        return HStack(spacing: 12) {
            // -- thumbnail placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: isActive ? 0.2 : 0.13))
                    .frame(width: 100, height: 64)
                Image(systemName: isActive ? "waveform" : "play.fill")
                    .foregroundColor(isActive ? accent : .white.opacity(0.5))
                    .font(.system(size: isActive ? 16 : 18))
            }

            VStack(alignment: .leading, spacing: 5) {
                // -- judul klip
                Text(other.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(isActive ? accent : .white)

                // -- mode recording (Auto / Manual)
                HStack(spacing: 6) {
                    Label(other.mode == .auto ? "Auto" : "Manual",
                          systemImage: other.mode == .auto ? "wand.and.stars" : "hand.tap")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))

                    Text("·")
                        .foregroundColor(.white.opacity(0.3))

                    // -- tanggal & waktu rekaman
                    Text(formatRecordedAt(other.recordedAt))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }

                // -- durasi
                Text(formatDuration(other.duration))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isActive ? Color(white: 0.12) : Color.clear)
    }

    // MARK: - add to album sheet (diambil dari ClipSelectionBottomBar)

    private var addToAlbumSheetContent: some View {
        NavigationView {
            ZStack {
                Color(white: 0.1).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // -- tombol buat album baru
                        Button(action: { showNewAlbumAlert = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                                    .font(.system(size: 24))
                                Text("New Album")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color(white: 0.2))
                            .cornerRadius(12)
                        }

                        Divider().background(Color.gray).padding(.vertical, 8)

                        if dummyAlbums.isEmpty {
                            Text("No existing albums.")
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        } else {
                            ForEach(dummyAlbums.indices, id: \.self) { index in
                                Button(action: { addToExistingAlbum(at: index) }) {
                                    HStack {
                                        Text(dummyAlbums[index].title)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(dummyAlbums[index].clips.count) clips")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(white: 0.15))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add to Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { showAddToAlbumSheet = false }
                        .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                }
            }
        }
    }

    // -- tambah satu klip ke album yang sudah ada
    private func addToExistingAlbum(at index: Int) {
        let albumName = dummyAlbums[index].title
        let result = dummyAlbums[index].addUniqueClips([clip])
        showAddToAlbumSheet = false

        if result.added > 0 {
            toast.show("Added to \(albumName)")
        } else {
            toast.show("Already exists in \(albumName)")
        }
    }

    // -- buat album baru lalu tambah klip ini ke dalamnya
    private func createNewAlbumAndAdd() {
        guard !newAlbumName.isEmpty else { return }
        let name = newAlbumName
        let newAlbum = Album(
            title: name,
            coverColor: Color(white: Double.random(in: 0.1...0.3)),
            clips: [clip]
        )
        dummyAlbums.append(newAlbum)
        newAlbumName = ""
        showAddToAlbumSheet = false
        toast.show("Added to new album \"\(name)\"")
    }

    // MARK: - helpers

    private func relatedClips() -> [Clip] {
        switch source {
        case .album(let album):   return album.clips
        case .session(let session): return session.clips
        case .favorites:          return dummySessions.flatMap { $0.clips }.filter { $0.isFavorite }
        case .none:               return []
        }
    }

    private func sourceLabel() -> String {
        switch source {
        case .album(let album):     return "From album · \(album.title)"
        case .session(let session): return "From session · \(session.title)"
        case .favorites:            return "From favorites"
        case .none:                 return ""
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }

    private func formatRecordedAt(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy · HH:mm"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }
}

// MARK: - video surface (AVPlayerLayer langsung, tanpa native controls)

struct VideoSurfaceView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.setPlayer(player)
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.setPlayer(player)
    }
}

class PlayerUIView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    func setPlayer(_ player: AVPlayer) {
        (layer as? AVPlayerLayer)?.player = player
        (layer as? AVPlayerLayer)?.videoGravity = .resizeAspect
    }
}

// MARK: - view model

class PlayerViewModel: ObservableObject {

    let player: AVPlayer
    private let clip: Clip

    @Published var isPlaying = false
    @Published var isFinished = false
    @Published var progress: Double = 0
    @Published var currentTimeString = "0:00"
    @Published var durationString = "0:00"
    @Published var playbackSpeed: Float = 1.0
    @Published var isFavorite: Bool
    @Published var showControls = true
    @Published var isScrubbing = false

    private var timeObserver: Any?
    private var hideControlsTask: DispatchWorkItem?

    init(clip: Clip) {
        self.clip = clip
        self.isFavorite = clip.isFavorite

        let url = clip.videoURL ?? Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4")!
        self.player = AVPlayer(url: url)

        setupObservers()
        player.play()
        isPlaying = true
        scheduleHideControls()
    }

    deinit {
        if let obs = timeObserver { player.removeTimeObserver(obs) }
        NotificationCenter.default.removeObserver(self)
    }

    private func setupObservers() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self, !self.isScrubbing else { return }
            let current = time.seconds
            let duration = self.player.currentItem?.duration.seconds ?? 0
            guard duration > 0, !duration.isNaN else { return }
            self.progress = current / duration
            self.currentTimeString = self.formatTime(current)
            self.durationString = self.formatTime(duration)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish),
            name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    @objc private func videoDidFinish() {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isFinished = true
            self.showControls = true
        }
    }

    func togglePlayPause() {
        if isFinished { restartVideo(); return }
        isPlaying ? pause() : play()
        scheduleHideControls()
    }

    func play() {
        player.play()
        isPlaying = true
        isFinished = false
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func restartVideo() {
        player.seek(to: .zero)
        isFinished = false
        play()
    }

    func setSpeed(_ speed: Float) {
        playbackSpeed = speed
        player.rate = speed
        isPlaying = true
    }

    func seekToProgress() {
        let duration = player.currentItem?.duration.seconds ?? 0
        guard duration > 0 else { return }
        let target = CMTime(seconds: progress * duration, preferredTimescale: 600)
        player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func toggleFavorite() {
        isFavorite.toggle()
        for sIndex in dummySessions.indices {
            for cIndex in dummySessions[sIndex].clips.indices {
                if dummySessions[sIndex].clips[cIndex].id == clip.id {
                    dummySessions[sIndex].clips[cIndex].isFavorite = isFavorite
                }
            }
        }
    }

    func deleteClip() {
        for sIndex in dummySessions.indices {
            dummySessions[sIndex].clips.removeAll { $0.id == clip.id }
        }
        dummySessions.removeAll { $0.clips.isEmpty }
        for aIndex in dummyAlbums.indices {
            dummyAlbums[aIndex].clips.removeAll { $0.id == clip.id }
        }
    }

    private func scheduleHideControls() {
        hideControlsTask?.cancel()
        showControls = true
        let task = DispatchWorkItem { [weak self] in
            withAnimation { self?.showControls = false }
        }
        hideControlsTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: task)
    }

    private func formatTime(_ seconds: Double) -> String {
        String(format: "%d:%02d", Int(seconds) / 60, Int(seconds) % 60)
    }
}
