//import SwiftUI
//
//// MARK: - Toast View Modifier
//// Cara pakai:
////   .toastOverlay(message: toastMessage, isShowing: $showToast)
//
//struct ToastOverlayModifier: ViewModifier {
//    let message: String
//    @Binding var isShowing: Bool
//
//    func body(content: Content) -> some View {
//        ZStack(alignment: .top) {
//            content
//            if isShowing {
//                ToastOverlayView(message: message)
//            }
//        }
//    }
//}
//
//// MARK: - Toast View
//struct ToastOverlayView: View {
//    let message: String
//
//    var body: some View {
//        VStack {
//            Text(message)
//                .font(.system(size: 13, weight: .semibold, design: .rounded))
//                .foregroundColor(.black)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(Color(red: 217/255, green: 255/255, blue: 78/255))
//                .clipShape(Capsule())
//                .shadow(
//                    color: Color(red: 217/255, green: 255/255, blue: 78/255).opacity(0.3),
//                    radius: 10, x: 0, y: 5
//                )
//                .padding(.top, 60)
//                .padding(.horizontal, 20)
//                .transition(.move(edge: .top).combined(with: .opacity))
//            Spacer()
//        }
//        .zIndex(100)
//    }
//}
//
//// MARK: - Toast State Manager
//// Gunakan di setiap View sebagai @StateObject
//class ToastManager: ObservableObject {
//    @Published var isShowing: Bool = false
//    @Published var message: String = ""
//
//    func show(_ message: String, duration: Double = 2.5) {
//        self.message = message
//        withAnimation(.spring()) {
//            isShowing = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//            withAnimation(.spring()) {
//                self.isShowing = false
//            }
//        }
//    }
//}
//
//// MARK: - View Extension (shortcut)
//extension View {
//    func toastOverlay(message: String, isShowing: Binding<Bool>) -> some View {
//        modifier(ToastOverlayModifier(message: message, isShowing: isShowing))
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    struct PreviewWrapper: View {
//        @StateObject private var toast = ToastManager()
//
//        var body: some View {
//            ZStack {
//                Color.black.ignoresSafeArea()
//                Button("Tampilkan Toast") {
//                    toast.show("Berhasil disimpan ke perangkat")
//                }
//                .foregroundColor(.white)
//            }
//            .toastOverlay(message: toast.message, isShowing: $toast.isShowing)
//        }
//    }
//    return PreviewWrapper()
//}
