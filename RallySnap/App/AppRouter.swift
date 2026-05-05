import SwiftUI
import Combine
import Foundation

enum AppRoute {
    case home
    case gallery
}

class AppRouter: ObservableObject {
    @Published var currentRoute: AppRoute = .home
    @Published var showCamera: Bool = false
    @Published var isTabBarHidden: Bool = false
    @Published var showSplash: Bool = true
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                self.showSplash = false
            }
        }
    }

    func finishOnboarding() {
        hasSeenOnboarding = true
    }
}
