import Foundation

struct Clip: Identifiable {
    let id = UUID()
    let title: String
    let recordedAt: Date
    let duration: TimeInterval
    let mode: ClipMode
    let videoURL: URL?
    var isFavorite: Bool = false
}

enum ClipMode: String {
    case auto = "A"
    case manual = "M"
}
