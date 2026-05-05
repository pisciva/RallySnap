import SwiftUI

struct ClipSelectionBottomBar: View {
    @EnvironmentObject private var viewModel: GalleryViewModel
    
    @Binding var isSelectionMode: Bool
    @Binding var selectedClipIDs: Set<UUID>
    
    let selectedClips: [Clip]
    let onDelete: () -> Void
    let onAddedToAlbum: (String) -> Void
    let onFavorite: () -> Void
    let onSave: () -> Void
    
    @State private var showAddToAlbumSheet = false
    @State private var showNewAlbumAlert = false
    @State private var showDeleteConfirmation = false
    @State private var newAlbumName = ""
    
    private let accentColor = Color(red: 217/255, green: 1.0, blue: 78/255)
    
    var body: some View {
        let isAllFavorited = !selectedClips.isEmpty && selectedClips.allSatisfy { $0.isFavorite }
        
        VStack {
            Spacer()
            
            HStack(spacing: 0) {
                actionButton(icon: "folder.badge.plus", text: "Album", color: .white) {
                    if !selectedClipIDs.isEmpty {
                        showAddToAlbumSheet = true
                    }
                }
                
                actionButton(
                    icon: isAllFavorited ? "heart.slash" : "heart",
                    text: isAllFavorited ? "Unfavorite" : "Favorite",
                    color: isAllFavorited ? Color(white: 0.8) : .white
                ) {
                    onFavorite()
                }
                
                actionButton(icon: "arrow.down.to.line", text: "Save", color: .white) {
                    onSave()
                }
                
                actionButton(icon: "trash", text: "Delete", color: .red) {
                    showDeleteConfirmation = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(white: 0.1).ignoresSafeArea(edges: .bottom))
        }
        .transition(.move(edge: .bottom))
        .sheet(isPresented: $showAddToAlbumSheet) {
            addToAlbumSheetContent
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("New Album", isPresented: $showNewAlbumAlert) {
            TextField("Album Name", text: $newAlbumName)
            Button("Cancel", role: .cancel) { newAlbumName = "" }
            Button("Create") { createNewAlbumAndAddClips() }
        }
        .alert("Delete Clips", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { onDelete() }
        } message: {
            Text("Are you sure you want to delete \(selectedClipIDs.count) selected clips? This action cannot be undone.")
        }
    }
    
    private func actionButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(text)
                    .font(.system(size: 10, weight: .medium))
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(selectedClipIDs.isEmpty ? .gray : color)
        .disabled(selectedClipIDs.isEmpty)
    }
    
    private var addToAlbumSheetContent: some View {
        NavigationView {
            ZStack {
                Color(white: 0.1).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        Button(action: { showNewAlbumAlert = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(accentColor)
                                    .font(.system(size: 24))
                                
                                Text("New Album")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(white: 0.2))
                            .cornerRadius(12)
                        }
                        
                        Divider()
                            .background(Color.gray)
                            .padding(.vertical, 8)
                        
                        if viewModel.albums.isEmpty {
                            Text("No existing albums.")
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        } else {
                            ForEach(viewModel.albums.indices, id: \.self) { index in
                                Button(action: { addClipsToExistingAlbum(at: index) }) {
                                    HStack {
                                        Text(viewModel.albums[index].title)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text("\(viewModel.albums[index].clips.count) clips")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(white: 0.15))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add to Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { showAddToAlbumSheet = false }
                        .foregroundColor(accentColor)
                }
            }
        }
    }
    
    private func addClipsToExistingAlbum(at index: Int) {
        let albumName = viewModel.albums[index].title
        let alreadyExists = selectedClips.filter { viewModel.albums[index].clips.contains($0) }
        let toAdd = selectedClips.filter { !viewModel.albums[index].clips.contains($0) }
        
        selectedClips.forEach { viewModel.albums[index].addClip($0) }
        finishAddingToAlbum()
        
        let message: String
        if alreadyExists.isEmpty {
            message = "Added \(toAdd.count) clips to \(albumName)"
        } else if toAdd.isEmpty {
            message = "All \(alreadyExists.count) clips already exist in \(albumName)"
        } else {
            message = "Added \(toAdd.count) clips. \(alreadyExists.count) already exist"
        }
        
        onAddedToAlbum(message)
    }
    
    private func createNewAlbumAndAddClips() {
        if !newAlbumName.isEmpty {
            let name = newAlbumName
            viewModel.albums.append(Album(title: name, clips: selectedClips))
            newAlbumName = ""
            
            finishAddingToAlbum()
            onAddedToAlbum("Added \(selectedClips.count) clips to \(name)")
        }
    }
    
    private func finishAddingToAlbum() {
        showAddToAlbumSheet = false
        withAnimation(.easeInOut(duration: 0.2)) {
            isSelectionMode = false
            selectedClipIDs.removeAll()
        }
    }
}
