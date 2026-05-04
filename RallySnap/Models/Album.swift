import Foundation
import SwiftUI

struct Album: Identifiable {
    let id = UUID()
    var title: String
    let coverColor: Color
    var clips: [Clip]
    
    var latestClipURL: URL? {
        clips.sorted { $0.recordedAt > $1.recordedAt }.first?.videoURL
    }
    
    mutating func addUniqueClips(_ newClips: [Clip]) -> (added: Int, duplicate: Int) {
        let existingIDs = Set(clips.map { $0.id })
        
        let uniqueNewClips = newClips.filter { !existingIDs.contains($0.id) }
        clips.append(contentsOf: uniqueNewClips)
        
        let duplicatesCount = newClips.count - uniqueNewClips.count
        return (added: uniqueNewClips.count, duplicate: duplicatesCount)
    }
}
