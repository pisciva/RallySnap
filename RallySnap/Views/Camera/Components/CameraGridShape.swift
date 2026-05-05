import SwiftUI

struct CameraGridShape: Shape {
    var rows: Int = 3
    var columns: Int = 3
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let columnWidth = rect.width / CGFloat(columns)
        let rowHeight = rect.height / CGFloat(rows)
        
        for i in 1..<columns {
            let x = CGFloat(i) * columnWidth
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        for i in 1..<rows {
            let y = CGFloat(i) * rowHeight
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

