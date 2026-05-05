//
//  RootView.swift
//  RallySnap
//
//  Created by Belmiro Kayru on 05/05/26.
//
import SwiftUI

struct RootView: View {
    @State private var showSplash = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View{
        Group{
            if showSplash{
                SplashView()
            } else if hasSeenOnboarding {
                    TabBar()
                } else {
                OnBoardingView {
                    hasSeenOnboarding = true
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
                showSplash = false
            }
        }
    }
}
