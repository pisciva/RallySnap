import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject private var cameraManager = CameraManager.shared
    
    @State private var showExitConfirmation = false
    @State private var showTutorialOverlay = false
    @State private var showGrid = false
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        if cameraManager.permissionDenied {
            CameraPermissionView()
        } else {
            ZStack {
                
                // Grid Overlay
                if showGrid && !showTutorialOverlay {
                    CameraGridShape()
                        .stroke(Color.white.opacity(0.4), lineWidth: 0.75)
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                }
                
                // UI Controls Overlay
                if !showTutorialOverlay {
                    CameraControlsOverlay(
                        showExitConfirmation: $showExitConfirmation,
                        showGrid: $showGrid,
                        showTutorialOverlay: $showTutorialOverlay,
                        onFlipCamera: {
                            cameraManager.flipCamera()
                        },
                        onRecordTapped: {
                            cameraManager.toggleRecording()
                        },
                        currentZoom: cameraManager.currentZoom,
                        onZoomTapped: { factor in
                            cameraManager.setZoom(factor: factor)
                        },
                        isFrontCamera: cameraManager.isFrontCamera
                    ).rotateWithDevice()
                }
                // Recording Timer Overlay
                if cameraManager.isRecording && !showTutorialOverlay {
                    VStack {
                        HStack(spacing: 8) {
                            // Flashing red dot
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                // Add a subtle pulse animation to the dot
                                .opacity(cameraManager.recordingDuration.truncatingRemainder(dividingBy: 2) == 0 ? 1.0 : 0.4)
                                .animation(.easeInOut(duration: 0.5), value: cameraManager.recordingDuration)
                                .rotateWithDevice()
                            
                            // Formatted Time
                            Text(formatDuration(cameraManager.recordingDuration))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .rotateWithDevice()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 20)
                        
                        Spacer() // Pushes it to the top
                    }
                }
                
                // Tutorial Overlay
                if showTutorialOverlay {
                    TutorialView(isOverlay: true, onDismiss: {
                        showTutorialOverlay = false
                    })
                    .ignoresSafeArea()
                }
                
                if showExitConfirmation {
                    ExitConfirmationView(isPresented: $showExitConfirmation)
                }
            }
        }
    }
}

#Preview {
    CameraView()
}
