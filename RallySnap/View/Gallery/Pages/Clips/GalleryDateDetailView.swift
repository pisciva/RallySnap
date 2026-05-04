import SwiftUI

struct GalleryDateDetailView: View {
    let dateString: String
    @State private var sessions: [Session]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSelectionMode = false
    @State private var selectedClipIDs: Set<UUID> = []
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    init(dateString: String, sessions: [Session]) {
        self.dateString = dateString
        _sessions = State(initialValue: sessions)
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
            VStack(alignment: .leading) {
                ForEach(sessions) { session in
                    if !session.clips.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(session.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                                .padding(.horizontal, 16)
                            
                            ForEach(session.clips, id: \.id) { clip in
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
                }
            }
            .padding(.top, 80)
            .padding(.bottom, isSelectionMode ? 180 : 120)
        }
    }
    
    private var topBarSection: some View {
        ZStack {
            Text(dateString)
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
        withAnimation(.spring()) { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring()) { showToast = false }
        }
    }
    
    private var selectedClips: [Clip] {
        sessions.flatMap { $0.clips }.filter { selectedClipIDs.contains($0.id) }
    }
    
    
    private func deleteSingleClip(_ clip: Clip) {
        withAnimation(.easeInOut(duration: 0.2)) {
            for index in sessions.indices {
                sessions[index].clips.removeAll { $0.id == clip.id }
            }
            sessions.removeAll { $0.clips.isEmpty }
            
            for index in dummySessions.indices {
                dummySessions[index].clips.removeAll { $0.id == clip.id }
            }
            dummySessions.removeAll { $0.clips.isEmpty }
            
            if sessions.isEmpty { presentationMode.wrappedValue.dismiss() }
        }
        displayToast(message: "Successfully deleted \(clip.title)")
    }
    
    
    private func deleteSelectedClips() {
        let count = selectedClipIDs.count
        withAnimation(.easeInOut(duration: 0.2)) {
            for index in sessions.indices {
                sessions[index].clips.removeAll { selectedClipIDs.contains($0.id) }
            }
            sessions.removeAll { $0.clips.isEmpty }
            
            for index in dummySessions.indices {
                dummySessions[index].clips.removeAll { selectedClipIDs.contains($0.id) }
            }
            dummySessions.removeAll { $0.clips.isEmpty }
            
            selectedClipIDs.removeAll()
            isSelectionMode = false
            if sessions.isEmpty { presentationMode.wrappedValue.dismiss() }
        }
        displayToast(message: "Successfully deleted \(count) clips")
    }
    
    private func favoriteSelectedClips() {
        let isAllFavorited = selectedClips.allSatisfy { $0.isFavorite }
        let newState = !isAllFavorited
        let count = selectedClipIDs.count
        
        withAnimation(.easeInOut(duration: 0.2)) {
            for sIndex in sessions.indices {
                for cIndex in sessions[sIndex].clips.indices {
                    if selectedClipIDs.contains(sessions[sIndex].clips[cIndex].id) {
                        sessions[sIndex].clips[cIndex].isFavorite = newState
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
        }
        displayToast(message: "Successfully \(newState ? "Favorited" : "Unfavorited") \(count) clips")
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
