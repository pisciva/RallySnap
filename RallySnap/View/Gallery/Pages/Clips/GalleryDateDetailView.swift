import SwiftUI

struct GalleryDateDetailView: View {
    let dateString: String
    @State private var sessions: [Session]
    @Environment(\.presentationMode) var presentationMode
    
    @State var isSelectionMode = false
    @State var selectedClipIDs: Set<UUID> = []
    @StateObject private var toast = ToastManager()
    
    init(dateString: String, sessions: [Session]) {
        self.dateString = dateString
        _sessions = State(initialValue: sessions)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            contentSection
            DetailTopBar(
                title: dateString,
                isSelectionMode: $isSelectionMode,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onSelectionToggle: { selectedClipIDs.removeAll() }
            )
            
            if isSelectionMode {
                ClipSelectionBottomBar(
                    isSelectionMode: $isSelectionMode,
                    selectedClipIDs: $selectedClipIDs,
                    selectedClips: selectedClips,
                    onDelete: {
                        deleteSelectedClips(
                            localSessions: &sessions,
                            selectedClipIDs: &selectedClipIDs,
                            isSelectionMode: &isSelectionMode
                        ) {
                            if sessions.isEmpty { presentationMode.wrappedValue.dismiss() }
                        }
                    },
                    onAddedToAlbum: { message in toast.show(message) },
                    onFavorite: {
                        favoriteSelectedClips(
                            localSessions: &sessions,
                            selectedClipIDs: &selectedClipIDs,
                            isSelectionMode: &isSelectionMode
                        )
                    },
                    onSave: {
                        saveSelectedClips(
                            selectedClipIDs: &selectedClipIDs,
                            isSelectionMode: &isSelectionMode
                        )
                    }
                )
            }
        }
        .toastOverlay(message: toast.message, isShowing: $toast.isShowing)
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
                            
                            ForEach(session.clips) { clip in
                                SelectableClipRow(
                                    clip: clip,
                                    isSelectionMode: $isSelectionMode,
                                    selectedClipIDs: $selectedClipIDs,
                                    onDelete: {
                                        deleteSingleClip(
                                            clip,
                                            localSessions: &sessions
                                        ) {
                                            if sessions.isEmpty { presentationMode.wrappedValue.dismiss() }
                                        }
                                    },
                                    onToast: { message in toast.show(message) }
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
    
    private var selectedClips: [Clip] {
        sessions.flatMap { $0.clips }.filter { selectedClipIDs.contains($0.id) }
    }
}

extension GalleryDateDetailView: ClipActionHandler {
    func displayToast(message: String) {
        toast.show(message)
    }
}
