import SwiftUI

struct GalleryClipView: View {
    @Binding var showCalendarView: Bool
    
    var body: some View {
        if showCalendarView {
            GalleryCalendarModeView()
        } else {
            GalleryClipListView()
        }
    }
}

struct GalleryClipListView: View {
    @ObservedObject private var camera = CameraManager.shared  // ADD
    @State private var localSessions: [Session] = dummySessions

    var allSessions: [Session] {
        var sessions = dummySessions
        if !camera.currentSession.clips.isEmpty {
            sessions.append(camera.currentSession)
        }
        return sessions
    }

    var groupedSessions: [(String, [Session])] {
        let grouped = Dictionary(grouping: allSessions, by: { $0.dateString })  // change dummySessions → allSessions
        return grouped.map { ($0.key, $0.value) }.sorted {
            let date1 = $0.1.first?.createdAt ?? .distantPast
            let date2 = $1.1.first?.createdAt ?? .distantPast
            return date1 > date2
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                if groupedSessions.isEmpty {
                    Text("No clips available.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.4))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 60)
                } else {
                    ForEach(groupedSessions, id: \.0) { group in
                        DateSection(date: group.0, sessions: group.1)
                    }
                }
            }
            .padding(.top)
        }
        .onAppear { localSessions = dummySessions }
    }
}
