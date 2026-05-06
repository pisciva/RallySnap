//
//  ConfirmationPageView.swift
//  RallySnap Watch App
//
//  Created by Albert Tandy Harison on 04/05/26.
//

import SwiftUI

struct ConfirmationPageView: View {
    var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.neonGreen)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .stroke(Color.neonGreen.opacity(0.3), lineWidth: 4)
                    )
                    .shadow(color: .neonGreen.opacity(0.5), radius: 10)
                
                Text("Highlight Saved")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }    
}

#Preview {
    ConfirmationPageView().preferredColorScheme(.dark)
}
