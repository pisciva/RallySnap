//
//  MainPageView.swift
//  RallySnap Watch App
//
//  Created by Albert Tandy Harison on 04/05/26.
//

import SwiftUI

struct MainPageView: View {
    @EnvironmentObject var manager: SessionManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("P")
                    .foregroundColor(.neonGreen)
                Spacer()
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 8) {
                // Clips Card
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "video.badge.plus")
                        .foregroundColor(.neonGreen)
                        .padding(6)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("\(manager.totalClipsToday)")
                        .font(.system(size: 24, weight: .bold))
                    Text("CLIPS TODAY")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.darkCard)
                .cornerRadius(12)
                
                // Last Session Card
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.neonGreen)
                        .padding(6)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text(manager.formatTime(manager.lastSessionTime))
                        .font(.system(size: 14, weight: .bold))
                        .padding(.top, 10)
                    Text("LAST SESSION")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.darkCard)
                .cornerRadius(12)
            }
            
            Spacer()
            
            Button(action: {
                manager.startSession()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("START SESSION")
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
    MainPageView()
        .environmentObject(SessionManager())
        .preferredColorScheme(.dark)
}
