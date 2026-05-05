import SwiftUI

protocol ClipActionHandler {
    func displayToast(message: String)
}

extension ClipActionHandler {
    func favoriteSelectedClips(
        localSessions: inout [Session],
        selectedClipIDs: inout Set<UUID>,
        isSelectionMode: inout Bool,
        completion: (() -> Void)? = nil
    ) {
        let selected = localSessions
            .flatMap { $0.clips }
            .filter { selectedClipIDs.contains($0.id) }

        let isAllFavorited = selected.allSatisfy { $0.isFavorite }
        let newState = !isAllFavorited
        let count = selectedClipIDs.count

        withAnimation(.easeInOut(duration: 0.2)) {
            for sIndex in localSessions.indices {
                for cIndex in localSessions[sIndex].clips.indices {
                    if selectedClipIDs.contains(localSessions[sIndex].clips[cIndex].id) {
                        localSessions[sIndex].clips[cIndex].isFavorite = newState
                    }
                }
            }
            for sIndex in dummySessions.indices {
                for cIndex in dummySessions[sIndex].clips.indices {
                    if selectedClipIDs.contains(dummySessions[sIndex].clips[cIndex].id) {
                        dummySessions[sIndex].clips[cIndex].isFavorite = newState
                    }
                }
            }
            for aIndex in dummyAlbums.indices {
                for cIndex in dummyAlbums[aIndex].clips.indices {
                    if selectedClipIDs.contains(dummyAlbums[aIndex].clips[cIndex].id) {
                        dummyAlbums[aIndex].clips[cIndex].isFavorite = newState
                    }
                }
            }
            selectedClipIDs.removeAll()
            isSelectionMode = false
            completion?()
        }
        
        let actionText = newState ? "Favorited" : "Unfavorited"
        displayToast(message: "Successfully \(actionText) \(count) clips")
    }

    @discardableResult
    func deleteSelectedClips(
        localSessions: inout [Session],
        selectedClipIDs: inout Set<UUID>,
        isSelectionMode: inout Bool,
        completion: (() -> Void)? = nil
    ) -> Bool {
        let count = selectedClipIDs.count

        withAnimation(.easeInOut(duration: 0.2)) {
            for index in localSessions.indices {
                localSessions[index].clips.removeAll { selectedClipIDs.contains($0.id) }
            }
            localSessions.removeAll { $0.clips.isEmpty }

            for index in dummySessions.indices {
                dummySessions[index].clips.removeAll { selectedClipIDs.contains($0.id) }
            }
            dummySessions.removeAll { $0.clips.isEmpty }

            selectedClipIDs.removeAll()
            isSelectionMode = false
            completion?()
        }

        displayToast(message: "Successfully deleted \(count) clips")
        return localSessions.isEmpty
    }

    @discardableResult
    func deleteSingleClip(
        _ clip: Clip,
        localSessions: inout [Session],
        completion: (() -> Void)? = nil
    ) -> Bool {
        withAnimation(.easeInOut(duration: 0.2)) {
            for index in localSessions.indices {
                localSessions[index].clips.removeAll { $0.id == clip.id }
            }
            localSessions.removeAll { $0.clips.isEmpty }

            for index in dummySessions.indices {
                dummySessions[index].clips.removeAll { $0.id == clip.id }
            }
            dummySessions.removeAll { $0.clips.isEmpty }

            for index in dummyAlbums.indices {
                dummyAlbums[index].clips.removeAll { $0.id == clip.id }
            }
            completion?()
        }

        displayToast(message: "Successfully deleted \(clip.title)")
        return localSessions.isEmpty
    }

    func saveSelectedClips(
        selectedClipIDs: inout Set<UUID>,
        isSelectionMode: inout Bool,
        completion: (() -> Void)? = nil
    ) {
        let count = selectedClipIDs.count

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedClipIDs.removeAll()
            isSelectionMode = false
            completion?()
        }

        displayToast(message: "Successfully saved \(count) clips to device")
    }

    func favoriteClipsInAlbum(
        albumClips: inout [Clip],
        albumID: UUID,
        selectedClipIDs: inout Set<UUID>,
        isSelectionMode: inout Bool
    ) {
        let isAllFavorited = albumClips
            .filter { selectedClipIDs.contains($0.id) }
            .allSatisfy { $0.isFavorite }
        let newState = !isAllFavorited
        let count = selectedClipIDs.count

        withAnimation(.easeInOut(duration: 0.2)) {
            for cIndex in albumClips.indices {
                if selectedClipIDs.contains(albumClips[cIndex].id) {
                    albumClips[cIndex].isFavorite = newState
                }
            }
            for sIndex in dummySessions.indices {
                for cIndex in dummySessions[sIndex].clips.indices {
                    if selectedClipIDs.contains(dummySessions[sIndex].clips[cIndex].id) {
                        dummySessions[sIndex].clips[cIndex].isFavorite = newState
                    }
                }
            }
            for aIndex in dummyAlbums.indices {
                for cIndex in dummyAlbums[aIndex].clips.indices {
                    if selectedClipIDs.contains(dummyAlbums[aIndex].clips[cIndex].id) {
                        dummyAlbums[aIndex].clips[cIndex].isFavorite = newState
                    }
                }
            }
            selectedClipIDs.removeAll()
            isSelectionMode = false
        }

        let actionText = newState ? "Favorited" : "Unfavorited"
        displayToast(message: "Successfully \(actionText) \(count) clips")
    }

    func deleteClipsFromAlbum(
        albumClips: inout [Clip],
        albumID: UUID,
        selectedClipIDs: inout Set<UUID>,
        isSelectionMode: inout Bool
    ) {
        let count = selectedClipIDs.count

        withAnimation(.easeInOut(duration: 0.2)) {
            albumClips.removeAll { selectedClipIDs.contains($0.id) }

            if let albumIndex = dummyAlbums.firstIndex(where: { $0.id == albumID }) {
                dummyAlbums[albumIndex].clips.removeAll { selectedClipIDs.contains($0.id) }
            }

            selectedClipIDs.removeAll()
            isSelectionMode = false
        }

        displayToast(message: "Successfully deleted \(count) clips")
    }

    func deleteSingleClipFromAlbum(
        _ clip: Clip,
        albumClips: inout [Clip],
        albumID: UUID
    ) {
        withAnimation(.easeInOut(duration: 0.2)) {
            albumClips.removeAll { $0.id == clip.id }

            if let albumIndex = dummyAlbums.firstIndex(where: { $0.id == albumID }) {
                dummyAlbums[albumIndex].clips.removeAll { $0.id == clip.id }
            }
        }

        displayToast(message: "Successfully deleted \(clip.title)")
    }
}
