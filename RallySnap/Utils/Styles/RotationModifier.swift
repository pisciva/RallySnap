import SwiftUI

struct DeviceIconRotation: ViewModifier {
    @State private var angle: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(angle))
            .onAppear { updateAngle() }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    updateAngle()
                }
            }
    }
    
    private func updateAngle() {
        let orientation = UIDevice.current.orientation
        if orientation == .landscapeLeft {
            angle = 0
        } else if orientation == .landscapeRight {
            angle = 180
        }
    }
}

extension View {
    func rotateWithDevice() -> some View {
        self.modifier(DeviceIconRotation())
    }
}
