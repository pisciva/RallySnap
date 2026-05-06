//
//  SummaryPageView.swift
//  RallySnap Watch App
//
//  Created by Albert Tandy Harison on 04/05/26.
//

import SwiftUI

struct SummaryPageView: View {
    @EnvironmentObject var manager: SessionManager
    
    var body: some View {
            VStack(spacing: 8) {
                Text("SESSION COMPLETE")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.neonGreen)
                    .padding(.top, 10)
                
                VStack(spacing: 4) {
                    Text("TOTAL TIME")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                    Text(manager.formatTime(manager.currentSessionTime))
                        .font(.system(size: 20, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(Color.darkCard)
                .cornerRadius(12)
                
                VStack(spacing: 4) {
                    Text("TOTAL CLIPS")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                    Text("\(manager.currentSessionClips)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.neonGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(Color.darkCard)
                .cornerRadius(12)
                
                Spacer()
                
                Button(action: { manager.finishAndSave() }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("DONE")
                            .font(.system(size: 14, weight: .black))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonGreen)
                    .cornerRadius(24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        }    
}

#Preview {
    SummaryPageView()
        .environmentObject(SessionManager())
        .preferredColorScheme(.dark)
}
