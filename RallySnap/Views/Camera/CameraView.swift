import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject private var cameraManager = CameraManager.shared

    @State private var showExitConfirmation = false
    @State private var showTutorialOverlay = false
    @State private var showGrid = false

    // Auto-hide the last detected action after a few seconds
    @State private var actionBadgeVisible = false
    @State private var actionBadgeTimer: Task<Void, Never>? = nil

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

                if showGrid && !showTutorialOverlay {
                    CameraGridShape()
                        .stroke(Color.white.opacity(0.4), lineWidth: 0.75)
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                }

                if !showTutorialOverlay {
                    CameraControlsOverlay(
                        showExitConfirmation: $showExitConfirmation,
                        showGrid: $showGrid,
                        showTutorialOverlay: $showTutorialOverlay,
                        onFlipCamera: { cameraManager.flipCamera() },
                        onRecordTapped: { cameraManager.toggleRecording() },
                        currentZoom: cameraManager.currentZoom,
                        onZoomTapped: { factor in cameraManager.setZoom(factor: factor) },
                        isFrontCamera: cameraManager.isFrontCamera
                    ).rotateWithDevice()
                }

                if cameraManager.isRecording && !showTutorialOverlay {
                    VStack {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .opacity(cameraManager.recordingDuration.truncatingRemainder(dividingBy: 2) == 0 ? 1.0 : 0.4)
                                .animation(.easeInOut(duration: 0.5), value: cameraManager.recordingDuration)
                                .rotateWithDevice()

                            Text(formatDuration(cameraManager.recordingDuration))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .rotateWithDevice()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 20)

                        Spacer()
                    }
                }

                // Action badge — only when a shot fires
                if !showTutorialOverlay, actionBadgeVisible,
                   let action = cameraManager.lastDetectedAction {
                    VStack {
                        Spacer()
                        ActionBadge(action: action,
                                    confidence: cameraManager.lastDetectedConfidence)
                            .rotateWithDevice()
                            .padding(.bottom, 24)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }

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
            .onChange(of: cameraManager.lastDetectedAction) { _ in
                actionBadgeTimer?.cancel()
                withAnimation(.easeInOut(duration: 0.25)) { actionBadgeVisible = true }
                actionBadgeTimer = Task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.25)) { actionBadgeVisible = false }
                    }
                }
            }
        }
    }
}

// MARK: - Action Badge

private struct ActionBadge: View {
    let action: String
    let confidence: Float

    var body: some View {
        HStack(spacing: 8) {
            Text("🎾 \(action.capitalized)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.neonGreen)
            Text("\(Int(confidence * 100))%")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

#Preview {
    CameraView()
}
