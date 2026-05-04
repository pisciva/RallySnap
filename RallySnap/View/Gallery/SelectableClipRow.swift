import SwiftUI

struct SelectableClipRow: View {
    let clip: Clip
    @Binding var isSelectionMode: Bool
    @Binding var selectedClipIDs: Set<UUID>
    
    // Jalur Komunikasi Baru
    let onDelete: () -> Void
    let onToast: (String) -> Void
    
    var body: some View {
        let isSelected = selectedClipIDs.contains(clip.id)
        
        HStack(spacing: 0) {
            if isSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color(red: 217/255, green: 255/255, blue: 78/255) : .gray)
                    .padding(.trailing, 12)
            }
            
            ClipCardView(
                clip: clip,
                onDelete: onDelete, // Diteruskan
                onToast: onToast    // Diteruskan
            )
            .allowsHitTesting(!isSelectionMode)
        }
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelectionMode {
                if isSelected {
                    selectedClipIDs.remove(clip.id)
                } else {
                    selectedClipIDs.insert(clip.id)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelectionMode)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
