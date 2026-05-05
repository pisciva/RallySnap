import SwiftUI

struct ReusableToggleStyle: ToggleStyle {
    var tint: Color = .green
    var scale: CGFloat = 1.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            ZStack {
                Capsule()
                    .fill(configuration.isOn ? tint : Color.outergrey)
                    .frame(width: 76, height: 40)
                
                HStack {
                    if configuration.isOn {
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 2, height: 16)
                            .padding(.leading, 16)
                        Spacer()
                    } else {
                        Spacer()
                        Circle()
                            .stroke(Color(white: 0.6), lineWidth: 2.5)
                            .frame(width: 14, height: 14)
                            .padding(.trailing, 16)
                    }
                }
                .frame(width: 76)
                
                Capsule()
                    .fill(Color.white)
                    .frame(width: 40, height: 34)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                    .offset(x: configuration.isOn ? 16 : -16)
                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: configuration.isOn)
            }
            .scaleEffect(scale)
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}
