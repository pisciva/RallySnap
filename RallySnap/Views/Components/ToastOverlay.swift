import SwiftUI
import Combine

struct ToastModifier: ViewModifier {
    let message: String
    @Binding var isShowing: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isShowing {
                Text(message)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 217/255, green: 1.0, blue: 78/255))
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 217/255, green: 1.0, blue: 78/255).opacity(0.3), radius: 10, y: 5)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
            }
        }
    }
}

class ToastManager: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var message: String = ""

    func show(_ message: String, duration: Double = 2.5) {
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

extension View {
    func toastOverlay(message: String, isShowing: Binding<Bool>) -> some View {
        self.modifier(ToastModifier(message: message, isShowing: isShowing))
    }
}
