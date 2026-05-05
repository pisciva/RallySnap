import Foundation

struct Session: Identifiable, Hashable, Equatable {
    let id = UUID()
    let title: String
    let createdAt: Date
    var clips: [Clip]
    
    var dateString: String {
        DateFormatter.sessionDate.string(from: createdAt)
    }
    
    var timeString: String {
        DateFormatter.sessionTime.string(from: createdAt)
    }
}
