//import SwiftUI
//
//// MARK: - ClipActionHandler Protocol
//// Adopsi protocol ini di setiap View yang butuh aksi terhadap klip.
//// Extension di bawah menyediakan implementasi default sehingga
//// AlbumDetailView, GalleryDateDetailView, dan view lainnya
//// tidak perlu menulis ulang logika yang sama.
////
//// Cara pakai di View:
////   1. Tambahkan `extension NamaView: ClipActionHandler {}`
////   2. Panggil method langsung: deleteSelectedClips(), favoriteSelectedClips(), dst.
//
//protocol ClipActionHandler: AnyObject {
//
//    // MARK: - Required: State yang harus dimiliki adopting view
//    var selectedClipIDs: Set<UUID> { get set }
//    var isSelectionMode: Bool { get set }
//
//    // MARK: - Required: Callback untuk toast
//    func displayToast(message: String)
//}
//
//// MARK: - Default Implementations
//extension ClipActionHandler {
//
//    // MARK: Favorite / Unfavorite
//    /// Toggle status favorit untuk semua klip yang dipilih.
//    /// Update dilakukan ke 3 sumber: local sessions, dummySessions, dan dummyAlbums.
//    func favoriteSelectedClips(
//        localSessions: inout [Session],
//        completion: (() -> Void)? = nil
//    ) {
//        let selected = localSessions
//            .flatMap { $0.clips }
//            .filter { selectedClipIDs.contains($0.id) }
//
//        let isAllFavorited = selected.allSatisfy { $0.isFavorite }
//        let newState = !isAllFavorited
//        let count = selectedClipIDs.count
//
//        withAnimation(.easeInOut(duration: 0.2)) {
//            // 1. Update state lokal
//            for sIndex in localSessions.indices {
//                for cIndex in localSessions[sIndex].clips.indices {
//                    if selectedClipIDs.contains(localSessions[sIndex].clips[cIndex].id) {
//                        localSessions[sIndex].clips[cIndex].isFavorite = newState
//                    }
//                }
//            }
//
//            // 2. Update dummySessions (database pusat)
//            for sIndex in dummySessions.indices {
//                for cIndex in dummySessions[sIndex].clips.indices {
//                    if selectedClipIDs.contains(dummySessions[sIndex].clips[cIndex].id) {
//                        dummySessions[sIndex].clips[cIndex].isFavorite = newState
//                    }
//                }
//            }
//
//            // 3. Update dummyAlbums agar sinkron
//            for aIndex in dummyAlbums.indices {
//                for cIndex in dummyAlbums[aIndex].clips.indices {
//                    if selectedClipIDs.contains(dummyAlbums[aIndex].clips[cIndex].id) {
//                        dummyAlbums[aIndex].clips[cIndex].isFavorite = newState
//                    }
//                }
//            }
//
//            selectedClipIDs.removeAll()
//            isSelectionMode = false
//            completion?()
//        }
//
//        let actionText = newState ? "Favorited" : "Unfavorited"
//        displayToast(message: "Successfully \(actionText) \(count) clips")
//    }
//
//    // MARK: Delete Selected (banyak klip via bottom bar)
//    /// Hapus semua klip yang dipilih dari local sessions dan dummySessions.
//    /// Kembalikan `true` jika setelah penghapusan tidak ada session tersisa.
//    @discardableResult
//    func deleteSelectedClips(
//        localSessions: inout [Session],
//        completion: (() -> Void)? = nil
//    ) -> Bool {
//        let count = selectedClipIDs.count
//
//        withAnimation(.easeInOut(duration: 0.2)) {
//            // Hapus dari local sessions
//            for index in localSessions.indices {
//                localSessions[index].clips.removeAll { selectedClipIDs.contains($0.id) }
//            }
//            localSessions.removeAll { $0.clips.isEmpty }
//
//            // Hapus dari database pusat
//            for index in dummySessions.indices {
//                dummySessions[index].clips.removeAll { selectedClipIDs.contains($0.id) }
//            }
//            dummySessions.removeAll { $0.clips.isEmpty }
//
//            selectedClipIDs.removeAll()
//            isSelectionMode = false
//            completion?()
//        }
//
//        displayToast(message: "Successfully deleted \(count) clips")
//        return localSessions.isEmpty
//    }
//
//    // MARK: Delete Single Clip (dari context menu / swipe)
//    /// Hapus satu klip dari local sessions, dummySessions, dan dummyAlbums.
//    /// Kembalikan `true` jika setelah penghapusan tidak ada session tersisa.
//    @discardableResult
//    func deleteSingleClip(
//        _ clip: Clip,
//        localSessions: inout [Session],
//        completion: (() -> Void)? = nil
//    ) -> Bool {
//        withAnimation(.easeInOut(duration: 0.2)) {
//            // Hapus dari local sessions
//            for index in localSessions.indices {
//                localSessions[index].clips.removeAll { $0.id == clip.id }
//            }
//            localSessions.removeAll { $0.clips.isEmpty }
//
//            // Hapus dari database pusat
//            for index in dummySessions.indices {
//                dummySessions[index].clips.removeAll { $0.id == clip.id }
//            }
//            dummySessions.removeAll { $0.clips.isEmpty }
//
//            // Hapus dari semua album
//            for index in dummyAlbums.indices {
//                dummyAlbums[index].clips.removeAll { $0.id == clip.id }
//            }
//
//            completion?()
//        }
//
//        displayToast(message: "Successfully deleted \(clip.title)")
//        return localSessions.isEmpty
//    }
//
//    // MARK: Save Selected
//    func saveSelectedClips(completion: (() -> Void)? = nil) {
//        let count = selectedClipIDs.count
//
//        withAnimation(.easeInOut(duration: 0.2)) {
//            selectedClipIDs.removeAll()
//            isSelectionMode = false
//            completion?()
//        }
//
//        displayToast(message: "Successfully saved \(count) clips to device")
//    }
//}
//
//// MARK: - Album Variant (tanpa sessions)
//// Untuk AlbumDetailView yang menyimpan [Clip] langsung, bukan [Session]
//extension ClipActionHandler {
//
//    func favoriteClipsInAlbum(
//        albumClips: inout [Clip],
//        albumID: UUID
//    ) {
//        let isAllFavorited = albumClips
//            .filter { selectedClipIDs.contains($0.id) }
//            .allSatisfy { $0.isFavorite }
//        let newState = !isAllFavorited
//        let count = selectedClipIDs.count
//
//        withAnimation(.easeInOut(duration: 0.2)) {
//            // 1. Update lokal
//            for cIndex in albumClips.indices {
//                if selectedClipIDs.contains(albumClips[cIndex].id) {
//                    albumClips[cIndex].isFavorite = newState
//                }
//            }
//            // 2. Sinkron ke dummySessions
//            for sIndex in dummySessions.indices {
//                for cIndex in dummySessions[sIndex].clips.indices {
//                    if selectedClipIDs.contains(dummySessions[sIndex].clips[cIndex].id) {
//                        dummySessions[sIndex].clips[cIndex].isFavorite = newState
//                    }
//                }
//            }
//            // 3. Sinkron ke semua album di dummy
//            for aIndex in dummyAlbums.indices {
//                for cIndex in dummyAlbums[aIndex].clips.indices {
//                    if selectedClipIDs.contains(dummyAlbums[aIndex].clips[cIndex].id) {
//                        dummyAlbums[aIndex].clips[cIndex].isFavorite = newState
//                    }
//                }
//            }
//
//            selectedClipIDs.removeAll()
//            isSelectionMode = false
//        }
//
//        let actionText = newState ? "Favorited" : "Unfavorited"
//        displayToast(message: "Successfully \(actionText) \(count) clips")
//    }
//
//    func deleteClipsFromAlbum(
//        albumClips: inout [Clip],
//        albumID: UUID
//    ) {
//        let count = selectedClipIDs.count
//
//        withAnimation(.easeInOut(duration: 0.2)) {
//            albumClips.removeAll { selectedClipIDs.contains($0.id) }
//
//            if let albumIndex = dummyAlbums.firstIndex(where: { $0.id == albumID }) {
//                dummyAlbums[albumIndex].clips.removeAll { selectedClipIDs.contains($0.id) }
//            }
//
//            selectedClipIDs.removeAll()
//            isSelectionMode = false
//        }
//
//        displayToast(message: "Successfully deleted \(count) clips")
//    }
//
//    func deleteSingleClipFromAlbum(
//        _ clip: Clip,
//        albumClips: inout [Clip],
//        albumID: UUID
//    ) {
//        withAnimation(.easeInOut(duration: 0.2)) {
//            albumClips.removeAll { $0.id == clip.id }
//
//            if let albumIndex = dummyAlbums.firstIndex(where: { $0.id == albumID }) {
//                dummyAlbums[albumIndex].clips.removeAll { $0.id == clip.id }
//            }
//        }
//
//        displayToast(message: "Successfully deleted \(clip.title)")
//    }
//}
