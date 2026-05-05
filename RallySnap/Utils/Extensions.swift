import Foundation

extension DateFormatter {
    static let sessionDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        f.locale = Locale(identifier: "id_ID")
        return f
    }()
    
    static let sessionTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        return f
    }()
}
