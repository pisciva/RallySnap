import SwiftUI

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

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    private let accent = Color(red: 217/255, green: 255/255, blue: 78/255)

    var currentMonthDate: Date {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 4
        let base = Calendar.current.date(from: comps) ?? Date()
        return Calendar.current.date(byAdding: .month, value: monthOffset, to: base) ?? Date()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                monthHeader
                calendarGrid
                dailySessionSection
            }
        }
        .onAppear { localSessions = dummySessions }
    }

    private var monthHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Text(monthString(from: currentMonthDate))
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                Text(yearString(from: currentMonthDate))
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
            }
            .foregroundColor(accent)

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
    }

    private var calendarGrid: some View {
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
                        .background(isSelected ? accent : Color.clear)
                        .clipShape(Circle())
                }

                Capsule()
                    .fill(hasSession ? accent : Color.clear)
                    .frame(width: 14, height: 4)
            } else {
                Color.clear.frame(width: 36, height: 46)
            }
        }
    }

    private var dailySessionSection: some View {
        let dailySessions = getSessions(for: selectedDate)
        let totalClips = dailySessions.reduce(0) { $0 + $1.clips.count }
        let destination = GalleryDateDetailView(dateString: formattedDate(selectedDate), sessions: dailySessions)

        return Group {
            if !dailySessions.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    NavigationLink(destination: destination) {
                        HStack {
                            Text("\(dailySessions.count) sessions | \(totalClips) clips")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(accent)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(accent)
                        }
                        .padding(.horizontal, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    ForEach(dailySessions) { session in
                        NavigationLink(destination: destination) {
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
        guard
            let range = calendar.range(of: .day, in: .month, for: currentMonthDate),
            let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonthDate))
        else { return [] }

        var days: [DateValue] = []

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        for _ in 0..<(firstWeekday - 1) {
            days.append(DateValue(day: -1, date: Date()))
        }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(DateValue(day: day, date: date))
            }
        }
        return days
    }

    func getSessions(for date: Date) -> [Session] {
        localSessions.filter { $0.dateString == formattedDate(date) }
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }

    func monthString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f.string(from: date)
    }

    func yearString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f.string(from: date)
    }
}
