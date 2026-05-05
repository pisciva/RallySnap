import SwiftUI

struct GalleryClipView: View {
    @Binding var showCalendarView: Bool
    
    var body: some View {
        if showCalendarView {
            GalleryClipCalendarView()
        } else {
            GalleryClipListView()
        }
    }
}

struct GalleryClipListView: View {
    @EnvironmentObject private var viewModel: GalleryViewModel
    @ObservedObject private var camera = CameraManager.shared

    var allSessions: [Session] {
        var sessions = viewModel.sessions
        if !camera.currentSession.clips.isEmpty {
            sessions.append(camera.currentSession)
        }
        return sessions
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                let groups = viewModel.groupSessions(allSessions)

                if groups.isEmpty {
                    Text("No clips available.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.4))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 60)
                } else {
                    ForEach(groups, id: \.0) { group in
                        DateSection(date: group.0, sessions: group.1)
                    }
                }
            }
            .padding(.top)
        }
    }
}
