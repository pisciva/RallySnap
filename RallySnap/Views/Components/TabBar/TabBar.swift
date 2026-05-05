import SwiftUI

struct TabBar: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $router.currentRoute) {
                HomeView()
                    .tag(AppRoute.home)
                    .toolbar(.hidden, for: .tabBar)
                
                GalleryView()
                    .tag(AppRoute.gallery)
                    .toolbar(.hidden, for: .tabBar)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 120)
            }
            
            ZStack(alignment: .bottom) {
                TabCurveShape()
                    .fill(Color(red: 26/255, green: 26/255, blue: 26/255))
                    .frame(width: 280, height: 65)
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                
                HStack {
                    TabButton(
                        icon: "house",
                        activeIcon: "house.fill",
                        text: "Home",
                        isSelected: router.currentRoute == .home
                    ) {
                        router.currentRoute = .home
                    }
                    
                    CameraButtonView {
                        router.showCamera = true
                    }
                    
                    TabButton(
                        icon: "circle.grid.2x2",
                        activeIcon: "circle.grid.2x2.fill",
                        text: "Gallery",
                        isSelected: router.currentRoute == .gallery
                    ) {
                        router.currentRoute = .gallery
                    }
                }
                .padding(.horizontal, 10)
                .frame(width: 280, height: 65)
            }
            .offset(y: router.isTabBarHidden ? 150 : 0)
            .opacity(router.isTabBarHidden ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: router.isTabBarHidden)
        }
        .fullScreenCover(isPresented: $router.showCamera) {
            CameraContainerView()
        }
    }
}
