//
//  SessionPageView.swift
//  RallySnap Watch App
//
//  Created by Albert Tandy Harison on 04/05/26.
//

import SwiftUI

struct SessionPageView: View {
    @EnvironmentObject var manager: SessionManager
    
    var body: some View {
            ZStack {
                VStack {
                    HStack {
                        Button(action: { manager.requestEndSession() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red)
                                .frame(width: 30, height: 30)
                                .background(Color.darkCard)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text(manager.formatTime(manager.currentSessionTime))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.neonGreen)
                            .padding(.leading, -40)
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal, 8)
                    
                    Spacer()
                    
                    ZStack {
                        Image("TennisBall")
                            .resizable() // Wajib agar bisa diubah ukurannya
                                    .scaledToFit() // Menjaga rasio gambar
                                    .frame(width: 160, height: 160)
                                    .foregroundColor(.neonGreen) // Jika SVG kamu bertipe 'Template Image'
                                    .shadow(color: .neonGreen.opacity(0.4), radius: 20)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 32))
                            Text("CLIP RALLY")
                                .font(.system(size: 14, weight: .black))
                        }
                        .foregroundColor(.black)
                    }
                    .onTapGesture(count: 2) {
                        manager.clipRally()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                        Text("Double Tap to Clip")
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.darkCard)
                    .cornerRadius(15)
                }
            }
        }
    }

#Preview {
    SessionPageView()
        .environmentObject(SessionManager())
        .preferredColorScheme(.dark)
}
