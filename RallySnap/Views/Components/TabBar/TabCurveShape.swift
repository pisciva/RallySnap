import SwiftUI

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
