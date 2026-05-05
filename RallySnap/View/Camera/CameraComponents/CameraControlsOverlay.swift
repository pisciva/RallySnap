import SwiftUI

struct CameraControlsOverlay: View {
    @Binding var showExitConfirmation: Bool
    @Binding var showGrid: Bool
    @Binding var showTutorialOverlay: Bool
    var onFlipCamera: () -> Void
    var onRecordTapped: () -> Void
    var currentZoom: CGFloat
    var onZoomTapped: (CGFloat) -> Void
    var isFrontCamera: Bool
    
    var body: some View {
        HStack {
            //left sidebar
            ZStack {
                Color.clear.background(.ultraThinMaterial)
                
                VStack {
                    Button(action: { showExitConfirmation = true }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.neonGreen)
                            .padding(16)
                            .background(Circle().fill(Color.black.opacity(0.3)).overlay(Circle().stroke(Color.white.opacity(0.3))))
                            .rotateWithDevice()
                    }
                    
                    Spacer()
                    
                    Button(action: { showGrid.toggle() }) {
                        Image(systemName: "square.grid.3x3")
                            .font(.system(size: 20))
                            .foregroundColor(showGrid ? .black : .neonGreen)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.3)).overlay(Circle().stroke(Color.white.opacity(0.3))))
                            .rotateWithDevice()
                    }
                }
                .padding(.vertical, 30)
            }
            .frame(width: 80)
            .padding(.leading, 16)
            
            Spacer()
            
            //record button
            Button(action: onRecordTapped) {
                ZStack {
                    // Outer non-animating white ring
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 70, height: 70)
                    
                    // Inner animating red shape
                    RoundedRectangle(cornerRadius: CameraManager.shared.isRecording ? 8 : 30)
                        .fill(Color.red)
                        .frame(
                            width: CameraManager.shared.isRecording ? 35 : 60,
                            height: CameraManager.shared.isRecording ? 35 : 60
                        )
                }
                .animation(.easeInOut(duration: 0.2), value: CameraManager.shared.isRecording)
            }
            .padding(.trailing, 20)
            
            //right sidebar
            ZStack {
                Color.clear.background(.ultraThinMaterial)
                
                VStack {
                    Button(action: onFlipCamera) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 20))
                            .foregroundColor(.neonGreen)
                            .padding(16)
                            .background(Circle().fill(Color.black.opacity(0.3)).overlay(Circle().stroke(Color.white.opacity(0.3))))
                            .rotateWithDevice()
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        ZoomButton(label: "2", factor: 2.0, currentZoom: currentZoom, action: onZoomTapped).rotateWithDevice()
                        ZoomButton(label: "1", factor: 1.0, currentZoom: currentZoom, action: onZoomTapped).rotateWithDevice()
                        ZoomButton(label: "0.5", factor: 0.5, currentZoom: currentZoom, action: onZoomTapped).rotateWithDevice()
                    
                    }
                    .padding(.vertical, 12)
                    .frame(width: 48)
                    .background(Capsule().fill(Color.black.opacity(0.4)).background(.ultraThinMaterial, in: Capsule()))
                    
                    Spacer()
                    
                    Button(action: { showTutorialOverlay.toggle() }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.neonGreen)
                            .padding(16)
                            .background(Circle().fill(Color.black.opacity(0.3)).overlay(Circle().stroke(Color.white.opacity(0.3))))
                            .rotateWithDevice()
                    }
                }
                .padding(.vertical, 30)
            }
            .frame(width: 80)
            .padding(.trailing, 16)
        }
        .ignoresSafeArea()
    }
}

struct ZoomButton: View {
    let label: String
    let factor: CGFloat
    let currentZoom: CGFloat
    let action: (CGFloat) -> Void
    
    var isSelected: Bool {
        abs(currentZoom - factor) < 0.1
    }
    
    var displayLabel: String {
        isSelected ? "\(label)x" : label
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action(factor)
            }
        }) {
            Text(displayLabel)
                .font(.system(size: isSelected ? 15 : 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .neonGreen : .white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.black.opacity(isSelected ? 0.3 : 0.0))
                        .frame(width: 44, height: 44)
                )
        }
    }
}
