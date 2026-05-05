import SwiftUI

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
