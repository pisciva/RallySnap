import SwiftUI

struct DetailTopBar: View {
    let title: String
    @Binding var isSelectionMode: Bool
    
    var onBack: () -> Void
    var onSelectionToggle: (() -> Void)?
    var showSelectButton: Bool
    
    private let accent = Color(red: 217/255, green: 255/255, blue: 78/255)
    
    init(
        title: String,
        isSelectionMode: Binding<Bool>,
        onBack: @escaping () -> Void,
        onSelectionToggle: (() -> Void)? = nil,
        showSelectButton: Bool = true
    ) {
        self.title = title
        self._isSelectionMode = isSelectionMode
        self.onBack = onBack
        self.onSelectionToggle = onSelectionToggle
        self.showSelectButton = showSelectButton
    }
    
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
                        .foregroundColor(accent)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                if showSelectButton {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSelectionMode.toggle()
                            if !isSelectionMode {
                                onSelectionToggle?()
                            }
                        }
                    }) {
                        Text(isSelectionMode ? "Cancel" : "Select")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(isSelectionMode ? .white : .black)
                            .frame(width: 80, height: 44)
                            .background(isSelectionMode ? Color(white: 0.2) : accent)
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
            Rectangle()
                .fill(Color.black.opacity(0.85))
                .ignoresSafeArea(edges: .top)
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isSelectionMode = false
        
        var body: some View {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("Konten di bawah top bar")
                        .foregroundColor(.white)
                        .padding(.top, 100)
                    
                    Spacer()
                }
                
                DetailTopBar(
                    title: "April 2026",
                    isSelectionMode: $isSelectionMode,
                    onBack: { print("Back ditekan") },
                    onSelectionToggle: { print("Selection dibersihkan") }
                )
            }
        }
    }
    
    return PreviewWrapper()
}
