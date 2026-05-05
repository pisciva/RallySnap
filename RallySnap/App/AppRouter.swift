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
}
