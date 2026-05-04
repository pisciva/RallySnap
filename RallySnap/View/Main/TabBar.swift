import SwiftUI

// MARK: - 1. Pemancar Sinyal (PreferenceKey)
struct TabBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct TabBar: View {
    @State private var selectedTab: Int = 0
    @State private var isHoldingCamera: Bool = false
    
    // MARK: - 2. State penentu sembunyi/muncul
    @State private var isTabBarHidden: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            
            Group {
                if selectedTab == 0 {
                    HomeView()
                } else if selectedTab == 2 {
                    GalleryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 120)
            }
            
            // Custom Tab Bar
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
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    Button(action: { print("buka kamera") }) {
                        VStack(spacing: 4) {
                            Image("ball")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 65, height: 65)
                                .shadow(color: Color(red: 180/255, green: 255/255, blue: 0/255).opacity(0.25), radius: 10, x: 0, y: 0)
                                .rotationEffect(.degrees(isHoldingCamera ? 360 : 0))
                                .opacity(isHoldingCamera ? 0.3 : 1.0)
                                .animation(
                                    isHoldingCamera
                                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                                        : .easeInOut(duration: 0.3),
                                    value: isHoldingCamera
                                )
                                .offset(y: -45)
                                .padding(.bottom, -45)
                            
                            Text("Camera")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isHoldingCamera = true
                            }
                            .onEnded { _ in
                                isHoldingCamera = false
                            }
                    )

                    TabButton(
                        icon: "circle.grid.2x2",
                        activeIcon: "circle.grid.2x2.fill",
                        text: "Gallery",
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal, 10)
                .frame(width: 280, height: 65)
            }
            // MARK: - 3. Animasi Tab Bar Turun ke Bawah saat disembunyikan
            .offset(y: isTabBarHidden ? 150 : 0)
            .opacity(isTabBarHidden ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: isTabBarHidden)
        }
        // MARK: - 4. Penerima Sinyal
        .onPreferenceChange(TabBarHiddenPreferenceKey.self) { isHidden in
            isTabBarHidden = isHidden
        }
    }
}

// ... Sisanya tetap sama (TabButton dan TabCurveShape)
struct TabButton: View {
    let icon: String
    let activeIcon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: isSelected ? activeIcon : icon)
                    .font(.system(size: 24, weight: .semibold))
                
                Text(text)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? Color(red: 217/255, green: 255/255, blue: 78/255) : .white)
            .frame(maxWidth: .infinity)
        }
    }
}

struct TabCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius = rect.height / 2
        
        path.move(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: rect.height))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height / 2),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: -90),
                    clockwise: true)

        let bumpRadius: CGFloat = 36

        path.addLine(to: CGPoint(x: rect.width / 2 + bumpRadius, y: 0))
        path.addArc(center: CGPoint(x: rect.width / 2, y: 0),
                    radius: bumpRadius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 180),
                    clockwise: true)

        path.addLine(to: CGPoint(x: cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.height / 2),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 90),
                    clockwise: true)
        
        return path
    }
}
