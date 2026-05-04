import SwiftUI

struct GalleryAlbumView: View {
    @Binding var albums: [Album]
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    
    @State private var albumToRename: Album?
    @State private var showRenameAlert = false
    @State private var newAlbumName = ""
    
    
    @State private var albumToDelete: Album?
    @State private var showDeleteAlert = false
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(albums) { album in
                NavigationLink(destination: AlbumDetailView(album: album)) {
                    ZStack(alignment: .bottomLeading) {
                        if let videoURL = album.latestClipURL {
                            VideoThumbnailView(videoURL: videoURL)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(album.coverColor)
                                .aspectRatio(1, contentMode: .fill)
                        }
                        
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Text(album.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(16)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                .contextMenu {
                    Button(action: {
                        albumToRename = album
                        newAlbumName = album.title
                        showRenameAlert = true
                    }) {
                        Label("Rename Album", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        albumToDelete = album
                        showDeleteAlert = true
                    }) {
                        Label("Delete Album", systemImage: "trash")
                    }
                }
            }
        }
        .padding(16)
        
        .alert("Rename Album", isPresented: $showRenameAlert) {
            TextField("Album Name", text: $newAlbumName)
            Button("Cancel", role: .cancel) { newAlbumName = "" }
            Button("Save") { renameAlbum() }
        }
        
        .alert("Delete Album", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteAlbum() }
        } message: {
            Text("Are you sure you want to delete this album? The clips inside will remain in your gallery.")
        }
    }
    
    
    
    private func renameAlbum() {
        guard let album = albumToRename, !newAlbumName.isEmpty else { return }
        
        
        if let index = albums.firstIndex(where: { $0.id == album.id }) {
            albums[index].title = newAlbumName
        }
        
        if let dummyIndex = dummyAlbums.firstIndex(where: { $0.id == album.id }) {
            dummyAlbums[dummyIndex].title = newAlbumName
        }
    }
    
    private func deleteAlbum() {
        guard let album = albumToDelete else { return }
        
        withAnimation {
            
            albums.removeAll { $0.id == album.id }
            
            dummyAlbums.removeAll { $0.id == album.id }
        }
    }
}
