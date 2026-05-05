import SwiftUI
import Combine

struct ToastOverlayModifier: ViewModifier {
    let message: String
    @Binding var isShowing: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if isShowing {
                ToastOverlayView(message: message)
            }
        }
    }
}

struct ToastOverlayView: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 217/255, green: 255/255, blue: 78/255))
                .clipShape(Capsule())
                .shadow(
                    color: Color(red: 217/255, green: 255/255, blue: 78/255).opacity(0.3),
                    radius: 10, x: 0, y: 5
                )
                .padding(.top, 60)
                .padding(.horizontal, 20)
                .transition(.move(edge: .top).combined(with: .opacity))
            
            Spacer()
        }
        .zIndex(100)
    }
}

class ToastManager: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var message: String = ""

    // function to show toast message
    func show(_ message: String, duration: Double = 2.5) {
        DispatchQueue.main.async {
            self.message = message
            withAnimation(.spring()) {
                self.isShowing = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.spring()) {
                    self.isShowing = false
                }
            }
        }
    }
}

extension View {
    func toastOverlay(message: String, isShowing: Binding<Bool>) -> some View {
        modifier(ToastOverlayModifier(message: message, isShowing: isShowing))
    }
}
