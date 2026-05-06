//
//  SessionManager.swift
//  RallySnap Watch App
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
    @Published var lastSessionTime: TimeInterval = 0

    @Published var currentSessionTime: TimeInterval = 0
    @Published var currentSessionClips: Int = 0

    /// How far back the iPhone should clip when we tap CLIP RALLY.
    /// Can wire this to a setting screen later — default 5s feels right
    /// for "I just hit a great shot, save what just happened".
    var clipLookbackSeconds: Double = 5.0

    private var timer: Timer?

    func startSession() {
        currentSessionTime = 0
        currentSessionClips = 0
        currentScreen = .session
        WatchConnectivityManager.shared.sendStartSession()
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentSessionTime += 1
        }
    }

    func clipRally() {
        // Tell the iPhone to save the last N seconds.
        WatchConnectivityManager.shared.sendClipCommand(lookback: clipLookbackSeconds)

        currentSessionClips += 1
        totalClipsToday += 1
        currentScreen = .confirmation

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
        WatchConnectivityManager.shared.sendEndSession()
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
