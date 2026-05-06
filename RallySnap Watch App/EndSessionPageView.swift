//
//  EndSessionPageView.swift
//  RallySnap Watch App
//
//  Created by Albert Tandy Harison on 04/05/26.
//

import SwiftUI

struct EndSessionPageView: View {
    @EnvironmentObject var manager: SessionManager
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.red)
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.2))
                .clipShape(Circle())
            
            Text("End Session?")
                .font(.system(size: 16, weight: .bold))
            
            Text("Are you sure you want to\nend your current session?")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: { manager.cancelEnd() }) {
                    VStack {
                        Image(systemName: "xmark")
                        Text("CANCEL")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.darkCard)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                Button(action: { manager.confirmEndSession() }) {
                    VStack {
                        Image(systemName: "checkmark")
                        Text("END")
                            .font(.system(size: 10, weight: .bold)).padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .frame(height: 50)
        }
        .padding(.top, 10)
    }
}

#Preview {
    EndSessionPageView()
        .environmentObject(SessionManager())
}
