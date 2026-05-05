import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

@main
struct RallySnapApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var router = AppRouter()
    @StateObject private var galleryViewModel = GalleryViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if router.showSplash {
                    SplashView()
                } else if !router.hasSeenOnboarding {
                    OnBoardingView {
                        router.finishOnboarding()
                    }
                } else {
                    TabBar()
                        .environmentObject(router)
                        .environmentObject(galleryViewModel)
                }
            }
        }
    }
}
