import SwiftUI

// MARK: - Player Overlay

struct PlayerOverlayView: View {
    let isLandscape: Bool
    let isFavorite: Bool
    @ObservedObject var vm: PlayerViewModel

    var onDismiss: () -> Void
    var onToggleFavorite: () -> Void
    var onAddToAlbum: () -> Void
    var onSave: () -> Void
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            gradientVignette

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
        .opacity(vm.showControls ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: vm.showControls)
        .onTapGesture { vm.toggleControls() }
    }

    // MARK: Gradient

    private var gradientVignette: some View {
        VStack {
            LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 100)
            Spacer()
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                .frame(height: 160)
        }
    }

    // MARK: Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 217/255, green: 1.0, blue: 78/255))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            Spacer()
            Text(vm.currentClip.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
            speedMenu
        }
        .padding(.horizontal, 16)
        .padding(.top, isLandscape ? 12 : 50)
    }

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
                .background(Color(red: 217/255, green: 1.0, blue: 78/255))
                .clipShape(Capsule())
        }
    }

    // MARK: Center Play Button

    private var centerPlayButton: some View {
        Button(action: { vm.togglePlayPause() }) {
            Image(systemName: vm.isFinished ? "arrow.counterclockwise" : (vm.isPlaying ? "pause.fill" : "play.fill"))
                .font(.system(size: 36))
                .foregroundColor(.white)
                .frame(width: 72, height: 72)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }

    // MARK: Timeline Bar

    private var timelineBar: some View {
        VStack(spacing: 4) {
            Slider(value: $vm.progress, in: 0...1, onEditingChanged: { editing in
                vm.isScrubbing = editing
                if !editing { vm.seekToProgress() }
            })
            .accentColor(Color(red: 217/255, green: 1.0, blue: 78/255))

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

    // MARK: Bottom Controls

    private var bottomControls: some View {
        HStack(spacing: 0) {
            actionButton(icon: isFavorite ? "heart.fill" : "heart", color: isFavorite ? .red : .white,   label: isFavorite ? "Unfavorite" : "Favorite", action: onToggleFavorite)
            actionButton(icon: "folder.badge.plus",                  color: .white,                      label: "Add to Album",                          action: onAddToAlbum)
            actionButton(icon: "arrow.down.to.line",                 color: .white,                      label: "Save",                                  action: onSave)
            actionButton(icon: "trash",                              color: .red,                        label: "Delete",                                action: onDelete)
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
}

// MARK: - Related Clips List

struct RelatedClipsListView: View {
    @ObservedObject var vm: PlayerViewModel
    let source: PlayerSource
    let clips: [Clip]
    let sourceLabel: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if clips.isEmpty {
                    Text("No other clips available.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 32)
                } else {
                    Text(sourceLabel)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 8)

                    ForEach(clips) { clip in
                        clipRow(clip)
                            .onTapGesture { vm.switchClip(clip) }

                        Divider()
                            .background(Color.white.opacity(0.07))
                            .padding(.leading, 128)
                    }
                }
            }
        }
        .background(Color(white: 0.07))
    }

    private func clipRow(_ clip: Clip) -> some View {
        let isActive = clip.id == vm.currentClip.id
        let accent = Color(red: 217/255, green: 1.0, blue: 78/255)

        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: isActive ? 0.2 : 0.13))
                    .frame(width: 100, height: 64)
                Image(systemName: isActive ? "waveform" : "play.fill")
                    .foregroundColor(isActive ? accent : .white.opacity(0.5))
                    .font(.system(size: isActive ? 16 : 18))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(clip.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(isActive ? accent : .white)

                HStack(spacing: 6) {
                    Label(
                        clip.mode == .auto ? "Auto" : "Manual",
                        systemImage: clip.mode == .auto ? "wand.and.stars" : "hand.tap"
                    )
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))

                    Text("·").foregroundColor(.white.opacity(0.3))

                    Text(vm.formatRecordedAt(clip.recordedAt))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }

                Text(vm.formatDuration(clip.duration))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isActive ? Color(white: 0.12) : Color.clear)
        .contentShape(Rectangle())
    }
}

// MARK: - Add To Album Sheet

struct AddToAlbumSheetView: View {
    let clip: Clip
    @EnvironmentObject private var galleryVM: GalleryViewModel

    @Binding var isPresented: Bool
    @Binding var showNewAlbumAlert: Bool

    var onToast: (String) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                Color(white: 0.1).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        Button(action: { showNewAlbumAlert = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(red: 217/255, green: 1.0, blue: 78/255))
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

                        if galleryVM.albums.isEmpty {
                            Text("No existing albums.")
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        } else {
                            ForEach(galleryVM.albums.indices, id: \.self) { index in
                                Button(action: { addToExistingAlbum(at: index) }) {
                                    HStack {
                                        Text(galleryVM.albums[index].title)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(galleryVM.albums[index].clips.count) clips")
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
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(Color(red: 217/255, green: 1.0, blue: 78/255))
                }
            }
        }
    }

    private func addToExistingAlbum(at index: Int) {
        let albumName = galleryVM.albums[index].title
        let alreadyExists = galleryVM.albums[index].clips.contains(clip)
        galleryVM.albums[index].addClip(clip)
        isPresented = false
        onToast(alreadyExists ? "Already exists in \(albumName)" : "Added to \(albumName)")
    }
}
