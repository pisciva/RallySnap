import SwiftUI

struct AlbumDetailView: View {
    @State private var album: Album
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSelectionMode = false
    @State private var selectedClipIDs: Set<UUID> = []
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    init(album: Album) {
        _album = State(initialValue: album)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            contentSection
            topBarSection
            
            if isSelectionMode {
                ClipSelectionBottomBar(
                    isSelectionMode: $isSelectionMode,
                    selectedClipIDs: $selectedClipIDs,
                    selectedClips: selectedClips,
                    onDelete: deleteSelectedClips,
                    onAddedToAlbum: { message in
                        displayToast(message: message)
                    },
                    onFavorite: favoriteSelectedClips,
                    onSave: saveSelectedClips
                )
            }
            
            if showToast {
                toastOverlay
            }
        }
        .navigationBarHidden(true)
        .preference(key: TabBarHiddenPreferenceKey.self, value: isSelectionMode)
    }
    
    private var contentSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                if album.clips.isEmpty {
                    Text("No clips in this album yet.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.top, 60)
                } else {
                    ForEach(album.clips) { clip in
                        SelectableClipRow(
                            clip: clip,
                            isSelectionMode: $isSelectionMode,
                            selectedClipIDs: $selectedClipIDs,
                            
                            onDelete: { deleteSingleClip(clip) },
                            onToast: { message in displayToast(message: message) }
                        )
                    }
                }
            }
            .padding(.top, 80)
            .padding(.bottom, isSelectionMode ? 180 : 120)
        }
    }
    
    private var topBarSection: some View {
        ZStack {
            Text(album.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                if !album.clips.isEmpty || isSelectionMode {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSelectionMode.toggle()
                            if !isSelectionMode { selectedClipIDs.removeAll() }
                        }
                    }) {
                        Text(isSelectionMode ? "Cancel" : "Select")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(isSelectionMode ? .white : .black)
                            .frame(width: 80, height: 44)
                            .background(isSelectionMode ? Color(white: 0.2) : Color(red: 217/255, green: 255/255, blue: 78/255))
                            .clipShape(Capsule())
                    }
                } else {
                    Color.clear.frame(width: 80, height: 44)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Rectangle().fill(Color.black.opacity(0.85)).ignoresSafeArea(edges: .top))
    }
    
    private var toastOverlay: some View {
        VStack {
            Text(toastMessage)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 217/255, green: 255/255, blue: 78/255))
                .clipShape(Capsule())
                .shadow(color: Color(red: 217/255, green: 255/255, blue: 78/255).opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.top, 60)
                .padding(.horizontal, 20)
                .transition(.move(edge: .top).combined(with: .opacity))
            Spacer()
        }
        .zIndex(100)
    }
    
    private func displayToast(message: String) {
        toastMessage = message
        withAnimation(.spring()) {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring()) {
                showToast = false
            }
        }
    }
    
    private var selectedClips: [Clip] {
        album.clips.filter { selectedClipIDs.contains($0.id) }
    }
    
    
    private func deleteSingleClip(_ clip: Clip) {
        withAnimation(.easeInOut(duration: 0.2)) {
            
            album.clips.removeAll { $0.id == clip.id }
            
            
            if let albumIndex = dummyAlbums.firstIndex(where: { $0.id == album.id }) {
                dummyAlbums[albumIndex].clips.removeAll { $0.id == clip.id }
            }
        }
        displayToast(message: "Successfully deleted \(clip.title)")
    }
    

    private func deleteSelectedClips() {
        let count = selectedClipIDs.count
        withAnimation(.easeInOut(duration: 0.2)) {
            album.clips.removeAll { selectedClipIDs.contains($0.id) }
            
            if let albumIndex = dummyAlbums.firstIndex(where: { $0.id == album.id }) {
                dummyAlbums[albumIndex].clips.removeAll { selectedClipIDs.contains($0.id) }
            }
            
            selectedClipIDs.removeAll()
            isSelectionMode = false
        }
        displayToast(message: "Successfully deleted \(count) clips")
    }
    
    private func favoriteSelectedClips() {
        let isAllFavorited = selectedClips.allSatisfy { $0.isFavorite }
        let newState = !isAllFavorited
        let count = selectedClipIDs.count
        
        withAnimation(.easeInOut(duration: 0.2)) {
            
            for cIndex in album.clips.indices {
                if selectedClipIDs.contains(album.clips[cIndex].id) {
                    album.clips[cIndex].isFavorite = newState
                }
            }
            
            a
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
    
    private func saveSelectedClips() {
        let count = selectedClipIDs.count
        
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedClipIDs.removeAll()
            isSelectionMode = false
        }
        
        displayToast(message: "Successfully saved \(count) clips to device")
    }
}
