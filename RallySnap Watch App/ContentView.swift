//
//  ContentView.swift
//  RallySnap Watch App
//
//  Created by Albert Tandy Harison on 06/05/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = SessionManager()
    
    var body: some View {
        Group {
            switch sessionManager.currentScreen {
            case .main:
                MainPageView()
            case .session:
                SessionPageView()
            case .confirmation:
                ConfirmationPageView()
            case .endPrompt:
                EndSessionPageView()
            case .summary:
                SummaryPageView()
            }
        }
        .environmentObject(sessionManager)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

