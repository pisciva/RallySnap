import SwiftUI

struct ClipCardView: View {
    let clip: Clip
    let onDelete: () -> Void
    let onToast: (String) -> Void
    
    @State private var isShowingPlayer = false
    @State private var isFavorite: Bool
    @State private var showAddToAlbumSheet = false
    @State private var showNewAlbumAlert = false
    @State private var showDeleteConfirmation = false
    @State private var newAlbumName = ""
    
    init(clip: Clip, onDelete: @escaping () -> Void, onToast: @escaping (String) -> Void) {
        self.clip = clip
        self.onDelete = onDelete
        self.onToast = onToast
        self._isFavorite = State(initialValue: clip.isFavorite)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                isShowingPlayer = true
            }) {
                HStack(spacing: 16) {
                    thumbnailSection
                    infoSection
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            optionMenu
        }
        .padding(.vertical, 8)
        .background(Color.black)
        .fullScreenCover(isPresented: $isShowingPlayer) {
            ClipPlayerView(clip: clip)
        }
        .onChange(of: clip.isFavorite) { newValue in
            isFavorite = newValue
        }
        .sheet(isPresented: $showAddToAlbumSheet) {
            addToAlbumSheetContent
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("New Album", isPresented: $showNewAlbumAlert) {
            TextField("Album Name", text: $newAlbumName)
            Button("Cancel", role: .cancel) { newAlbumName = "" }
            Button("Create") { createNewAlbumAndAddClip() }
        }
        .alert("Delete Clip", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { onDelete() }
        } message: {
            Text("Are you sure you want to delete '\(clip.title)'? This action cannot be undone.")
        }
    }
    
    private var thumbnailSection: some View {
        ZStack(alignment: .center) {
            VideoThumbnailView(videoURL: clip.videoURL)
                .frame(width: 100, height: 70)
                .cornerRadius(8)
            
            Image(systemName: "play.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text("\(Int(clip.duration))s")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                        .padding(4)
                }
            }
        }
        .frame(width: 100, height: 70)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(clip.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(dateTimeString(from: clip.recordedAt))
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(Color(white: 0.6))
            
            HStack(spacing: 8) {
                Text(clip.mode == .auto ? "A" : "M")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(width: 20, height: 20)
                    .background(Color(red: 217/255, green: 255/255, blue: 78/255))
                    .clipShape(Circle())
                
                if isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    private var optionMenu: some View {
        Menu {
            Button(action: { showAddToAlbumSheet = true }) {
                Label("Add to Album", systemImage: "folder.badge.plus")
            }
            
            Button(action: toggleFavorite) {
                Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: isFavorite ? "heart.slash" : "heart")
            }
            
            Button(action: saveToGallery) {
                Label("Save to Gallery", systemImage: "arrow.down.to.line")
            }
            
            Divider()
            
            Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(white: 0.5))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
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
                        
                        Divider()
                            .background(Color.gray)
                            .padding(.vertical, 8)
                        
                        if dummyAlbums.isEmpty {
                            Text("No existing albums.")
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        } else {
                            ForEach(dummyAlbums.indices, id: \.self) { index in
                                Button(action: { addClipToExistingAlbum(at: index) }) {
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
    
    // function to format date
    private func dateTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        return formatter.string(from: date)
    }
    
    // function to toggle favorite
    private func toggleFavorite() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isFavorite.toggle()
        }
        
        for sIndex in dummySessions.indices {
            if let cIndex = dummySessions[sIndex].clips.firstIndex(where: { $0.id == clip.id }) {
                dummySessions[sIndex].clips[cIndex].isFavorite = isFavorite
            }
        }
        
        for aIndex in dummyAlbums.indices {
            if let cIndex = dummyAlbums[aIndex].clips.firstIndex(where: { $0.id == clip.id }) {
                dummyAlbums[aIndex].clips[cIndex].isFavorite = isFavorite
            }
        }
        
        onToast(isFavorite ? "Favorited \(clip.title)" : "Unfavorited \(clip.title)")
    }
    
    // function to save to gallery
    private func saveToGallery() {
        onToast("Successfully saved \(clip.title) to device")
    }
    
    // function to add clip to existing album
    private func addClipToExistingAlbum(at index: Int) {
        let albumName = dummyAlbums[index].title
        let result = dummyAlbums[index].addUniqueClips([clip])
        showAddToAlbumSheet = false
        
        if result.duplicate == 0 {
            onToast("Added \(clip.title) to \(albumName)")
        } else {
            onToast("\(clip.title) already exists in \(albumName)")
        }
    }
    
    // function to create new album and add clip
    private func createNewAlbumAndAddClip() {
        if !newAlbumName.isEmpty {
            let name = newAlbumName
            let newAlbum = Album(
                title: name,
                coverColor: Color(white: Double.random(in: 0.1...0.3)),
                clips: [clip]
            )
            
            dummyAlbums.append(newAlbum)
            newAlbumName = ""
            showAddToAlbumSheet = false
            onToast("Added \(clip.title) to \(name)")
        }
    }
}
