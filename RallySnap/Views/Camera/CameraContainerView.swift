import SwiftUI

enum CameraRoute {
    case tutorial
    case camera
}

struct CameraContainerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentRoute: CameraRoute
    
    // We can read showTutorialNextTime from AppStorage to decide initial route
    @AppStorage("showTutorialNextTime") private var showTutorialNextTime = true
    
    init() {
        let showTutorial = UserDefaults.standard.bool(forKey: "showTutorialNextTime")
        // Standard user defaults init fallback if not set is false, but default is true for @AppStorage
        // Wait, @AppStorage defaults to true if we pass it, so let's default to true
        let hasKey = UserDefaults.standard.object(forKey: "showTutorialNextTime") != nil
        let shouldShow = hasKey ? UserDefaults.standard.bool(forKey: "showTutorialNextTime") : true
        _currentRoute = State(initialValue: shouldShow ? .tutorial : .camera)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            CameraPreviewView(session: CameraManager.shared.session)
                .ignoresSafeArea()
            
            switch currentRoute {
            case .tutorial:
                TutorialView(isOverlay: false, onDismiss: {
                    currentRoute = .camera
                })
                .ignoresSafeArea()
            case .camera:
                CameraView()
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .onAppear {
            requestOrientation(.landscapeRight)
            CameraManager.shared.checkPermission()
        }
        .onDisappear {
            requestOrientation(.portrait)
            CameraManager.shared.stopSession()
        }
        // Instead of AppRouter, we pass a closure or use presentationMode? 
        // We'll solve the exit logic slightly differently.
    }
    
    private func requestOrientation(_ orientation: UIInterfaceOrientationMask) {
        AppDelegate.orientationLock = orientation
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
        
        rootViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
        
        if #available(iOS 16.0, *) {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation)) { error in
                print("Orientation update failed: \(error)")
            }
        } else {
            let val = orientation == .portrait ? UIInterfaceOrientation.portrait.rawValue : UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(val, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}
