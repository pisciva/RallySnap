//
//  WatchConnectivityManager.swift
//  RallySnap Watch App
//
//  Created by Albert Tandy Harison on 05/05/26.
//

import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Kirim perintah clip ke iPhone
    func sendClipCommand() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["action": "clip"], replyHandler: nil)
    }

    func sendStartSession() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["action": "startSession"], replyHandler: nil)
    }

    func sendEndSession() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["action": "endSession"], replyHandler: nil)
    }

    // Required delegates
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
    func sessionReachabilityDidChange(_ session: WCSession) {}
}
