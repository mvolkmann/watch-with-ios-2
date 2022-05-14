import SwiftUI
import WatchConnectivity

class ConnectionProvider: NSObject, WCSessionDelegate {
    static let instance = ConnectionProvider()
    let model = Model.instance
    
    //let session = WCSession.default
    let session: WCSession
    
    override init() {
        session = WCSession.default
        super.init()
        self.session.delegate = self
    }

    func extractValue(key: String, message: [String: Any]) -> Any? {
        do {
            if let bytes = message[key] as? Data {
                return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(bytes) as Any
            }
        } catch {
            print("ConnectionProvider.extractObject error \(error.localizedDescription)")
        }
        return nil
    }

    func sendValue(key: String, value: Any) {
        if !session.isReachable {
            print("ConnectionProvider.sendValue: session not reachable")
            print("Perhaps the companion app is not currently running.")
            return
        }
        
        do {
            let bytes = try NSKeyedArchiver.archivedData(
                withRootObject: value,
                requiringSecureCoding: true
            )

            // The WCSession sendMessage method requires
            // a Dictionary with String keys and Any values.
            let message = [key: bytes]
            session.sendMessage(message, replyHandler: nil) { error in
                print("ConnectionProvider.sendValue error: \(error)")
            }
        } catch {
            print("ConnectionProvider.sendValue: error \(error.localizedDescription)")
        }
    }

    // This is called on the phone and the watch when a
    // connection between the phone and watch is established.
    func session(
        _: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("ConnectionProvider.session: error \(error.localizedDescription)")
        } else {
            // notActivated = 0, inactive = 1, activated = 2
            print("ConnectionProvider.session: activationState = \(activationState.rawValue)")
            print("ConnectionProvider.session: reachable? \(session.isReachable)")
        }
    }

    #if os(iOS)
        // This is only available in iOS.  It is called when
        // there is a temporary disconnection between the phone and watch.
        func sessionDidBecomeInactive(_: WCSession) {
            print("phone/watch connection became inactive")
        }

        // This is only available in iOS.  It is called when
        // there is a permanent disconnection between the phone and watch.
        func sessionDidDeactivate(_: WCSession) {
            print("phone/watch connection was deactivated")
        }
    #endif

    // This is called when a message is received.
    func session(
        _: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        if let value = extractValue(key: "text", message: message) {
            let text = value as! String
            print("ConnectionProvider.session: text = \(text)")
            // Update the model on the main thread.
            Task {
                await MainActor.run { model.message = text }
            }

        }
    }
}
