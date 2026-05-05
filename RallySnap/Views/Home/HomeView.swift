import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: GalleryViewModel
    @EnvironmentObject private var router: AppRouter
    @State private var showGuidance = false
    @StateObject private var toast = ToastManager()
    
    private var recentClips: [Clip] {
        viewModel.sessions
            .flatMap { $0.clips }
            .sorted { $0.recordedAt > $1.recordedAt }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    guidanceSection
                    recentListSection
                }
                .padding(.bottom, 120)
            }
        }
        .fullScreenCover(isPresented: $showGuidance) {
            GuidanceView()
        }
        .toastOverlay(message: toast.message, isShowing: $toast.isShowing)
    }
    
    private var headerSection: some View {
        Text("Ready for a match?")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.top, 24)
    }
    
    private var guidanceSection: some View {
        Button(action: { showGuidance = true }) {
            VStack(spacing: 0) {
                Image("playtennis")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160, alignment: .bottom)
                    .clipped()
                
                HStack {
                    Text("Click For Guidance")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
    }
    
    private var recentListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recently Added")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    router.currentRoute = .gallery
                }) {
                    Text("View All")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 217/255, green: 1.0, blue: 78/255))
                }
            }
            .padding(.horizontal, 16)
            
            if recentClips.isEmpty {
                Text("No clips yet — open camera and start playing!")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 0) {
                    ForEach(recentClips.prefix(5)) { clip in
                        ClipCardView(
                            clip: clip,
                            onDelete: { viewModel.deleteClip(clip) },
                            onToast: { message in toast.show(message) }
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}
