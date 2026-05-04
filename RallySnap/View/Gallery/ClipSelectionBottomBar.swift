import SwiftUI

struct ClipSelectionBottomBar: View {
    @Binding var isSelectionMode: Bool
    @Binding var selectedClipIDs: Set<UUID>
    let selectedClips: [Clip]
    let onDelete: () -> Void
    let onAddedToAlbum: (String) -> Void
    let onFavorite: () -> Void
    let onSave: () -> Void // 1. Tambahan parameter onSave
    
    @State private var showAddToAlbumSheet = false
    @State private var showNewAlbumAlert = false
    @State private var showDeleteConfirmation = false
    @State private var newAlbumName = ""
    
    var body: some View {
        let isAllFavorited = !selectedClips.isEmpty && selectedClips.allSatisfy { $0.isFavorite }
        
        VStack {
            Spacer()
            // 2. Gunakan spacing 0 agar pembagian ruangnya murni dari maxWidth: .infinity
            HStack(spacing: 0) {
                // TOMBOL 1: Add to Album
                Button(action: {
                    if !selectedClipIDs.isEmpty {
                        showAddToAlbumSheet = true
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 20))
                        Text("Album") // Teks disingkat sedikit agar lebih rapi
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity) // Membagi ruang sama rata
                }
                .foregroundColor(selectedClipIDs.isEmpty ? .gray : .white)
                .disabled(selectedClipIDs.isEmpty)
                
                // TOMBOL 2: Favorite / Unfavorite
                Button(action: { onFavorite() }) {
                    VStack(spacing: 4) {
                        Image(systemName: isAllFavorited ? "heart.slash" : "heart")
                            .font(.system(size: 20))
                        Text(isAllFavorited ? "Unfavorite" : "Favorite")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundColor(selectedClipIDs.isEmpty ? .gray : (isAllFavorited ? Color(white: 0.8) : .white))
                .disabled(selectedClipIDs.isEmpty)
                
                // TOMBOL 3: Save to Gallery (Baru)
                Button(action: { onSave() }) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 20))
                        Text("Save")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundColor(selectedClipIDs.isEmpty ? .gray : .white)
                .disabled(selectedClipIDs.isEmpty)
                
                // TOMBOL 4: Delete
                Button(action: { showDeleteConfirmation = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                        Text("Delete")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundColor(selectedClipIDs.isEmpty ? .gray : .red)
                .disabled(selectedClipIDs.isEmpty)
            }
            .padding(.horizontal, 16) // Padding dikurangi sedikit karena ada 4 tombol
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
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedClipIDs.count) selected clips? This action cannot be undone.")
        }
    }
    
    // MARK: - Sheet Content Logic
    private var addToAlbumSheetContent: some View {
        NavigationView {
            ZStack {
                Color(white: 0.1).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        Button(action: { showNewAlbumAlert = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
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
                        
                        Divider().background(Color.gray).padding(.vertical, 8)
                        
                        if dummyAlbums.isEmpty {
                            Text("No existing albums.")
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        } else {
                            ForEach(dummyAlbums.indices, id: \.self) { index in
                                Button(action: {
                                    addClipsToExistingAlbum(at: index)
                                }) {
                                    HStack {
                                        Text(dummyAlbums[index].title)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(dummyAlbums[index].clips.count) clips")
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
                        .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                }
            }
        }
    }
    
    private func addClipsToExistingAlbum(at index: Int) {
        let albumName = dummyAlbums[index].title
        let result = dummyAlbums[index].addUniqueClips(selectedClips)
        finishAddingToAlbum()
        
        let message: String
        if result.duplicate == 0 {
            message = "Added \(result.added) clips to \(albumName)"
        } else if result.added == 0 {
            message = "All \(result.duplicate) clips already exist in \(albumName)"
        } else {
            message = "Added \(result.added) clips. \(result.duplicate) already exist"
        }
        
        onAddedToAlbum(message)
    }
    
    private func createNewAlbumAndAddClips() {
        if !newAlbumName.isEmpty {
            let name = newAlbumName
            let newAlbum = Album(title: name, coverColor: Color(white: Double.random(in: 0.1...0.3)), clips: selectedClips)
            dummyAlbums.append(newAlbum)
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
