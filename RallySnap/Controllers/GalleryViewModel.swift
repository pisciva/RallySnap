import Foundation
import Combine
import SwiftUI

class GalleryViewModel: ObservableObject {
    @Published var sessions: [Session] = dummySessions
    @Published var albums: [Album] = dummyAlbums

    func renameAlbum(_ album: Album, newTitle: String) {
        guard !newTitle.isEmpty else { return }
        if let index = albums.firstIndex(where: { $0.id == album.id }) {
            albums[index].title = newTitle
        }
    }

    func deleteAlbum(_ album: Album) {
        albums.removeAll { $0.id == album.id }
    }


    func groupSessions(_ sessions: [Session]) -> [(String, [Session])] {
        let grouped = Dictionary(grouping: sessions, by: { $0.dateString })
        return grouped.map { ($0.key, $0.value) }.sorted {
            ($0.1.first?.createdAt ?? .distantPast) > ($1.1.first?.createdAt ?? .distantPast)
        }
    }

    func deleteClips(ids: Set<UUID>, completion: (() -> Void)? = nil) {
        withAnimation {
            for i in sessions.indices {
                sessions[i].clips.removeAll { ids.contains($0.id) }
            }
            sessions.removeAll { $0.clips.isEmpty }
            completion?()
        }
    }

    func deleteClip(_ clip: Clip, completion: (() -> Void)? = nil) {
        withAnimation {
            for i in sessions.indices {
                sessions[i].clips.removeAll { $0.id == clip.id }
            }
            sessions.removeAll { $0.clips.isEmpty }
            for i in albums.indices {
                albums[i].clips.removeAll { $0.id == clip.id }
            }
            completion?()
        }
    }

    func deleteClipsFromAlbum(ids: Set<UUID>, albumID: UUID) {
        withAnimation {
            if let i = albums.firstIndex(where: { $0.id == albumID }) {
                albums[i].clips.removeAll { ids.contains($0.id) }
            }
        }
    }

    func deleteClipFromAlbum(_ clip: Clip, albumID: UUID) {
        withAnimation {
            if let i = albums.firstIndex(where: { $0.id == albumID }) {
                albums[i].clips.removeAll { $0.id == clip.id }
            }
        }
    }

    func toggleFavoriteClips(ids: Set<UUID>) {
        let allFavorited = sessions.flatMap { $0.clips }
            .filter { ids.contains($0.id) }
            .allSatisfy { $0.isFavorite }
        let newState = !allFavorited

        withAnimation {
            for si in sessions.indices {
                for ci in sessions[si].clips.indices where ids.contains(sessions[si].clips[ci].id) {
                    sessions[si].clips[ci].isFavorite = newState
                }
            }
            for ai in albums.indices {
                for ci in albums[ai].clips.indices where ids.contains(albums[ai].clips[ci].id) {
                    albums[ai].clips[ci].isFavorite = newState
                }
            }
        }
    }

    func toggleFavoriteClipsInAlbum(ids: Set<UUID>, albumID: UUID) {
        let allFavorited = albums.first(where: { $0.id == albumID })?.clips
            .filter { ids.contains($0.id) }
            .allSatisfy { $0.isFavorite } ?? false
        let newState = !allFavorited

        withAnimation {
            if let ai = albums.firstIndex(where: { $0.id == albumID }) {
                for ci in albums[ai].clips.indices where ids.contains(albums[ai].clips[ci].id) {
                    albums[ai].clips[ci].isFavorite = newState
                }
            }
            for si in sessions.indices {
                for ci in sessions[si].clips.indices where ids.contains(sessions[si].clips[ci].id) {
                    sessions[si].clips[ci].isFavorite = newState
                }
            }
        }
    }
}
