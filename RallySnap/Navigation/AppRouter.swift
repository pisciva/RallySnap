import SwiftUI
import Combine
import Foundation

enum AppRoute {
    case home
    case tutorial
    case camera
}

final class AppRouter: ObservableObject {
    @Published var currentRoute: AppRoute = .home
    @Published var tutorialPage: Int = 0
}
