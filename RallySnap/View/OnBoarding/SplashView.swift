//
//  SplashView.swift
//  RallySnap
//
//  Created by Belmiro Kayru on 05/05/26.
//
import SwiftUI

struct SplashView:View {
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            
            Image("PTennisLogo").resizable().scaledToFit().frame(width: 120, height: 120)
        }
    }
}
