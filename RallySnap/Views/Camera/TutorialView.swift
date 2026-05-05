import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("showTutorialNextTime") private var showTutorialNextTime = true
    @State private var currentPage = 0
    
    var isOverlay: Bool = false
    var onDismiss: () -> Void = {}
    
    init(isOverlay: Bool = false, onDismiss: @escaping () -> Void = {}) {
        self.isOverlay = isOverlay
        self.onDismiss = onDismiss
        UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            // 1. The Scrollable Pages
            TabView(selection: $currentPage) {
                TutorialPageOne(isOverlay: isOverlay).tag(0)
                TutorialPageTwo(isOverlay: isOverlay).tag(1)
                TutorialPageThree(isOverlay: isOverlay).tag(2)
                TutorialPageFour(
                    showTutorialNextTime: $showTutorialNextTime,
                    isOverlay: isOverlay,
                    onDismiss: onDismiss
                ).tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // 2. The Close Button Overlay
            .overlay(alignment: .topLeading) {
                ZStack {
                    VStack {
                        Button(action: {
                            if isOverlay {
                                onDismiss()
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.neonGreen)
                                .padding(16)
                                .background(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1).background(Circle().fill(Color.black.opacity(0.3))))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 30)
                }
                .frame(width: 80)
                .padding(.leading, 8)
            }
            
            // 3. The Custom Pagination Dots Overlay
            .overlay(alignment: .bottom) {
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(currentPage == index ? Color.neonGreen : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    TutorialView()
}
