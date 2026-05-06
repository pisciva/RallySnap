//
//  WatchConnectivityManager.swift
//  RallySnap Watch App
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

    /// Tell the paired iPhone to save the last `lookback` seconds as a clip.
    func sendClipCommand(lookback: Double = 5.0) {
        guard WCSession.default.isReachable else {
            print("Phone not reachable — clip command dropped")
            return
        }
        WCSession.default.sendMessage(
            ["action": "clip", "lookback": lookback],
            replyHandler: nil,
            errorHandler: { print("Clip send error: \($0)") }
        )
    }

    func sendStartSession() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["action": "startSession"], replyHandler: nil)
    }

    func sendEndSession() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["action": "endSession"], replyHandler: nil)
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {}
    func sessionReachabilityDidChange(_ session: WCSession) {}
}
