import Foundation

struct Session: Identifiable {
    let id = UUID()
    let title: String
    let createdAt: Date
    var clips: [Clip]
    
    var clipCount: Int { clips.count }
    
    var modes: [String] {
        var result: [String] = []
        if clips.contains(where: { $0.mode == .auto })   { result.append("A") }
        if clips.contains(where: { $0.mode == .manual }) { result.append("M") }
        return result
    }
    
    var date: String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        f.locale = Locale(identifier: "id_ID")
        return f.string(from: createdAt)
    }
    
    var time: String {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        return f.string(from: createdAt)
    }
}
