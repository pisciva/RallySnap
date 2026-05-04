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
    @State private var localSessions: [Session] = dummySessions
    
    var groupedSessions: [(String, [Session])] {
        let grouped = Dictionary(grouping: localSessions, by: { $0.date })
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
        .onAppear {
            localSessions = dummySessions
        }
    }
}

struct GalleryCalendarModeView: View {
    @State private var monthOffset: Int = 0
    @State private var localSessions: [Session] = dummySessions
    @State private var selectedDate: Date = {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 4
        comps.day = 29
        return Calendar.current.date(from: comps) ?? Date()
    }()
    
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var currentMonthDate: Date {
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 4
        let baseDate = calendar.date(from: comps) ?? Date()
        return calendar.date(byAdding: .month, value: monthOffset, to: baseDate) ?? Date()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    HStack(spacing: 8) {
                        Text(monthString(from: currentMonthDate))
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                        Text(yearString(from: currentMonthDate))
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: { withAnimation { monthOffset -= 1 } }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Button(action: { withAnimation { monthOffset += 1 } }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 8) {
                    HStack {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(white: 0.5))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                        ForEach(extractDates()) { value in
                            calendarCell(value)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                dailySessionSection
            }
        }
        .onAppear {
            localSessions = dummySessions
        }
    }
    
    @ViewBuilder
    private func calendarCell(_ value: DateValue) -> some View {
        VStack(spacing: 6) {
            if value.day != -1 {
                let isSelected = Calendar.current.isDate(selectedDate, inSameDayAs: value.date)
                let hasSession = !getSessions(for: value.date).isEmpty
                
                Button(action: { withAnimation { selectedDate = value.date } }) {
                    Text("\(value.day)")
                        .font(.system(size: 18, weight: isSelected ? .bold : .medium, design: .rounded))
                        .foregroundColor(isSelected ? .black : .white)
                        .frame(width: 36, height: 36)
                        .background(isSelected ? Color(red: 217/255, green: 255/255, blue: 78/255) : Color.clear)
                        .clipShape(Circle())
                }
                
                Capsule()
                    .fill(hasSession ? Color(red: 217/255, green: 255/255, blue: 78/255) : Color.clear)
                    .frame(width: 14, height: 4)
            } else {
                Color.clear.frame(width: 36, height: 46)
            }
        }
    }
    
    private var dailySessionSection: some View {
        let dailySessions = getSessions(for: selectedDate)
        
        return Group {
            if !dailySessions.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    let totalClips = dailySessions.reduce(0) { $0 + $1.clipCount }
                    
                    NavigationLink(destination: GalleryDateDetailView(dateString: formattedDate(selectedDate), sessions: dailySessions)) {
                        HStack {
                            Text("\(dailySessions.count) sessions | \(totalClips) clips")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                        }
                        .padding(.horizontal, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    ForEach(dailySessions) { session in
                        NavigationLink(destination: GalleryDateDetailView(dateString: formattedDate(selectedDate), sessions: dailySessions)) {
                            SessionCardView(session: session)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                VStack {
                    Spacer().frame(height: 40)
                    Text("No sessions on this date")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.4))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    func extractDates() -> [DateValue] {
        let calendar = Calendar.current
        let currentMonth = currentMonthDate
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else { return [] }
        
        var days: [DateValue] = []
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        for _ in 0..<(firstWeekday - 1) { days.append(DateValue(day: -1, date: Date())) }
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(DateValue(day: day, date: date))
            }
        }
        return days
    }
    
    func getSessions(for date: Date) -> [Session] {
        let dateStr = formattedDate(date)
        return localSessions.filter { $0.date == dateStr }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    func yearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

struct DateSection: View {
    let date: String
    let sessions: [Session]
    private let accent = Color(red: 217/255, green: 255/255, blue: 78/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(destination: GalleryDateDetailView(dateString: date, sessions: sessions)) {
                HStack {
                    Text(date)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(accent)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(accent)
                }
                .padding(.horizontal)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            ForEach(sessions) { session in
                NavigationLink(destination: GalleryDateDetailView(dateString: date, sessions: sessions)) {
                    SessionCardView(session: session)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}
