import Foundation
import WatchConnectivity

/// Listens for messages from the paired Apple Watch (RallySnap Watch App)
/// and forwards manual-clip commands to the iPhone-side ActionClassifierService.
class PhoneConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = PhoneConnectivityManager()

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Required delegate methods
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("Watch: activation error: \(error)")
        } else {
            print("Watch: connectivity activated, state=\(state.rawValue)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate so we can pair to a new watch
        WCSession.default.activate()
    }

    // MARK: - Receive messages

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let action = message["action"] as? String else { return }
        DispatchQueue.main.async {
            self.handle(action: action, message: message)
        }
    }

    private func handle(action: String, message: [String: Any]) {
        switch action {
        case "clip":
            // Optional: watch can send "lookback" (seconds, default 5)
            let lookback = message["lookback"] as? Double ?? 5.0
            print("Watch: clip command received (lookback=\(lookback)s)")
            CameraManager.shared.aiService?.saveManualClip(lookback: lookback)

        case "startSession":
            print("Watch: startSession received")
            // Hook up to your session start logic if needed

        case "endSession":
            print("Watch: endSession received")
            // Hook up to your session end logic if needed

        default:
            print("Watch: unknown action \(action)")
        }
    }
}
