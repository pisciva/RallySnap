import SwiftUI

struct DetailTopBar: View {
    let title: String
    @Binding var isSelectionMode: Bool
    
    var onBack: () -> Void
    var onSelectionToggle: (() -> Void)? = nil
    var showSelectButton: Bool = true
    
    private let accentColor = Color(red: 217/255, green: 1.0, blue: 78/255)
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 104)
            
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                if showSelectButton {
                    Button(action: toggleSelection) {
                        Text(isSelectionMode ? "Cancel" : "Select")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(isSelectionMode ? .white : .black)
                            .frame(width: 80, height: 44)
                            .background(isSelectionMode ? Color(white: 0.2) : accentColor)
                            .clipShape(Capsule())
                    }
                } else {
                    Color.clear.frame(width: 80, height: 44)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color.black.opacity(0.85)
                .ignoresSafeArea(edges: .top)
        )
    }
    
    private func toggleSelection() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isSelectionMode.toggle()
            if !isSelectionMode {
                onSelectionToggle?()
            }
        }
    }
}
