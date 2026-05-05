import SwiftUI

struct CameraPermissionView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "camera.fill.badge.ellipsis")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("Camera Access Required")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Please enable camera access in your device settings to record highlights.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
                
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding()
                .background(Color.neonGreen)
                .foregroundColor(.black)
                .cornerRadius(25)
                .font(.headline)
                .frame(width: 250)
                .rotateWithDevice()
            }
        }
    }
}
