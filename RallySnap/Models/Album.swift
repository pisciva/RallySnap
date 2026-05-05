import Foundation

struct Album: Identifiable {
    let id: UUID = UUID()
    var title: String
    var clips: [Clip]

    mutating func addClip(_ clip: Clip) {
        guard !clips.contains(clip) else { return }
        clips.append(clip)
    }
}
