import SwiftUI

struct CameraButtonView: View {
    @State private var isHoldingCamera: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image("ball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 65, height: 65)
                    .shadow(color: Color(red: 180/255, green: 255/255, blue: 0/255).opacity(0.25), radius: 10, x: 0, y: 0)
                    .rotationEffect(.degrees(isHoldingCamera ? 360 : 0))
                    .opacity(isHoldingCamera ? 0.3 : 1.0)
                    .animation(
                        isHoldingCamera
                            ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                            : .easeInOut(duration: 0.3),
                        value: isHoldingCamera
                    )
                    .offset(y: -45)
                    .padding(.bottom, -45)
                
                Text("Camera")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
            }
        }
        .frame(maxWidth: .infinity)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isHoldingCamera = true }
                .onEnded { _ in isHoldingCamera = false }
        )
    }
}
