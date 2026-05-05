import SwiftUI

struct DateSection: View {

    let date: String
    let sessions: [Session]
    @EnvironmentObject private var viewModel: GalleryViewModel

    private let accent = Color(red: 217/255, green: 255/255, blue: 78/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(destination: GalleryClipDetailView(dateString: date).environmentObject(viewModel)) {
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
                NavigationLink(destination: GalleryClipDetailView(dateString: date).environmentObject(viewModel)) {
                    SessionCardView(session: session)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
