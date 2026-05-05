import AVFoundation
import SwiftUI
import Combine

enum PlayerSource: Equatable {
    case album(Album)
    case session(Session)
    case favorites
    case none

    static func == (lhs: PlayerSource, rhs: PlayerSource) -> Bool {
        switch (lhs, rhs) {
        case (.album(let a), .album(let b)):     return a.id == b.id
        case (.session(let a), .session(let b)): return a.id == b.id
        case (.favorites, .favorites):           return true
        case (.none, .none):                     return true
        default:                                 return false
        }
    }
}

class PlayerViewModel: ObservableObject {
    @Published var currentClip: Clip
    @Published var isPlaying = false
    @Published var isFinished = false
    @Published var progress: Double = 0
    @Published var currentTimeString = "0:00"
    @Published var durationString = "0:00"
    @Published var playbackSpeed: Float = 1.0
    @Published var showControls = true
    @Published var isScrubbing = false

    let player: AVPlayer

    private var timeObserver: Any?
    private var hideControlsTask: DispatchWorkItem?

    init(clip: Clip) {
        self.currentClip = clip
        let url = clip.videoURL ?? Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4")!
        self.player = AVPlayer(url: url)
        setupTimeObserver()
        setupFinishObserver(for: player.currentItem)
        play()
    }

    deinit {
        if let obs = timeObserver { player.removeTimeObserver(obs) }
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Switch Clip

    func switchClip(_ clip: Clip) {
        guard clip.id != currentClip.id else { return }
        currentClip = clip

        let url = clip.videoURL ?? Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4")!
        let newItem = AVPlayerItem(url: url)

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.replaceCurrentItem(with: newItem)
        setupFinishObserver(for: newItem)

        progress = 0
        currentTimeString = "0:00"
        durationString = "0:00"
        isFinished = false
        playbackSpeed = 1.0
        player.rate = 1.0
        play()
    }

    // MARK: - Playback Controls

    func togglePlayPause() {
        if isFinished {
            player.seek(to: .zero)
            isFinished = false
            play()
        } else {
            isPlaying ? pause() : play()
        }
        scheduleHideControls()
    }

    func play() {
        player.play()
        isPlaying = true
        isFinished = false
        scheduleHideControls()
    }

    func pause() {
        player.pause()
        isPlaying = false
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

    func toggleControls() {
        showControls.toggle()
        if showControls && isPlaying {
            scheduleHideControls()
        } else {
            hideControlsTask?.cancel()
        }
    }

    // MARK: - Source Helpers

    func relatedClips(for source: PlayerSource, in galleryVM: GalleryViewModel) -> [Clip] {
        switch source {
        case .album(let album):
            return galleryVM.albums.first(where: { $0.id == album.id })?.clips ?? album.clips
        case .session(let session):
            return galleryVM.sessions.first(where: { $0.id == session.id })?.clips ?? session.clips
        case .favorites:
            return galleryVM.sessions.flatMap { $0.clips }.filter { $0.isFavorite }
        case .none:
            return []
        }
    }

    func sourceLabel(for source: PlayerSource) -> String {
        switch source {
        case .album(let album):      return "From album · \(album.title)"
        case .session(let session):  return "From session · \(session.title)"
        case .favorites:             return "From favorites"
        case .none:                  return ""
        }
    }

    func formatDuration(_ seconds: TimeInterval) -> String {
        String(format: "%d:%02d", Int(seconds) / 60, Int(seconds) % 60)
    }

    func formatRecordedAt(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy · HH:mm"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }

    // MARK: - Private

    private func setupTimeObserver() {
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
    }

    private func setupFinishObserver(for item: AVPlayerItem?) {
        guard let item else { return }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
    }

    @objc private func videoDidFinish() {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isFinished = true
            self.showControls = true
        }
    }

    private func scheduleHideControls() {
        hideControlsTask?.cancel()
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
