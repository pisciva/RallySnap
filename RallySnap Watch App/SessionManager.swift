//
//  SessionManager.swift
//  RallySnap Watch App
//
//  Created by Albert Tandy Harison on 04/05/26.
//

import SwiftUI
import Combine

extension Color {
    static let neonGreen = Color(red: 0.85, green: 1.0, blue: 0.31)
    static let darkCard = Color(white: 0.15)
}

enum AppScreen {
    case main, session, confirmation, endPrompt, summary
}

class SessionManager: ObservableObject {
    
    @Published var currentScreen: AppScreen = .main
    
    @Published var totalClipsToday: Int = 0
    @Published var lastSessionTime: TimeInterval = 0 // 01:02:03
    
    // Data Sesi Aktif
    @Published var currentSessionTime: TimeInterval = 0
    @Published var currentSessionClips: Int = 0
    
    private var timer: Timer?
    
    func startSession() {
        currentSessionTime = 0
        currentSessionClips = 0
        currentScreen = .session
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentSessionTime += 1
        }
    }
    
    func clipRally() {
        currentSessionClips += 1
        totalClipsToday += 1
        currentScreen = .confirmation
        
        // Halaman sukses tampil 1.5 detik, lalu otomatis kembali ke sesi
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.currentScreen == .confirmation {
                self.currentScreen = .session
            }
        }
    }
    
    func requestEndSession() {
        currentScreen = .endPrompt
    }
    
    func cancelEnd() {
        currentScreen = .session
    }
    
    func confirmEndSession() {
        timer?.invalidate()
        lastSessionTime = currentSessionTime
        currentScreen = .summary
    }
    
    func finishAndSave() {
        currentScreen = .main
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

