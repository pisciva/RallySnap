//
//  ClipCard.swift
//  tennis
//
//  Created by Albert Tandy Harison on 03/05/26.
//

import SwiftUI

struct ClipCard: View {
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            HStack(spacing: 10){
                Image("asset_homescreen_1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 110)
                    .clipped()
                
                VStack(alignment: .leading){
                    HStack(alignment: .top){
                        Text("Anjay forehand gua bagus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }.padding(.bottom, 4)
                    // Info Lokasi
                    Label("Terre Arena", systemImage: "mappin.and.ellipse")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    // Info Tanggal
                    Label("29 April 2026, 09:00 PM", systemImage: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    // Durasi & Label Auto Clip
                    HStack {
                        Label("1 min 20 sec", systemImage: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        // Kategori
                        Text("Auto Clip")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.85, green: 1.0, blue: 0.31))
                    }
                }
                .padding(.leading, 5)
                .padding(.trailing, 5)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ClipCard()
}
