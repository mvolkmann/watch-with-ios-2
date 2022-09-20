import SwiftUI
import WatchConnectivity

class ConnectionViewModel: NSObject, ObservableObject {
    @Published var message: [String: Any] = [:]

    static let shared = ConnectionViewModel()

    private let session = WCSession.default
    private let vm = ViewModel.shared

    private var lastMessageTime: CFAbsoluteTime = 0

    override private init() {
        super.init()
        session.delegate = self
        if WCSession.isSupported() {
            session.activate()
        }
    }

    func extractValue(key: String, message: [String: Any]) -> Any? {
        do {
            if let bytes = message[key] as? Data {
                return try NSKeyedUnarchiver
                    .unarchiveTopLevelObjectWithData(bytes) as Any
            }
        } catch {
            print(
                "ConnectionProvider.extractObject error \(error.localizedDescription)"
            )
        }
        return nil
    }

    func send(message: [String: Any]) {
        #if os(watchOS)
            guard WCSession.default.isCompanionAppInstalled else {
                print("ConnectionProvider.send: iPhone app is not installed")
                return
            }
        #else
            guard WCSession.default.isWatchAppInstalled else {
                print("ConnectionProvider.send: watch app is not installed")
                return
            }
        #endif

        session.transferUserInfo(message)

        /*
         // Limit the rate at which messages can be sent.
         let currentTime = CFAbsoluteTimeGetCurrent()
         guard currentTime >= lastMessageTime + 0.5 else { return }

         print("ConnectionProvider.send: message =", message)
         if session.isReachable {
             session.sendMessage(message, replyHandler: nil) { error in
                 print("ConnectionProvider.send: error = \(error)")
             }
         } else {
             print("ConnectionProvider.send: session is not reachable")
         }

         lastMessageTime = CFAbsoluteTimeGetCurrent()
         */
    }
}

extension ConnectionViewModel: WCSessionDelegate {
    // This is called on the phone and the watch when a
    // connection between the phone and watch is established.
    func session(
        _: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print(
                "ConnectionProvider.session: error \(error.localizedDescription)"
            )
        } else {
            // notActivated = 0, inactive = 1, activated = 2
            print(
                "ConnectionProvider.session: activationState = \(activationState.rawValue)"
            )
            print(
                "ConnectionProvider.session: reachable? \(session.isReachable)"
            )
        }
    }

    #if os(iOS)
        // This is only available in iOS.  It is called when there is
        // a temporary disconnection between the phone and watch.
        func sessionDidBecomeInactive(_: WCSession) {
            print("phone/watch connection became inactive")
        }

        // This is only available in iOS.  It is called when there is
        // a permanent disconnection between the phone and watch.
        func sessionDidDeactivate(_: WCSession) {
            print("phone/watch connection was deactivated")
            session.activate()
            session.delegate = self
        }
    #endif

    // This is called when a message is received.
    // @MainActor
    func session(
        _: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        print("ConnectionProvider.session: message =", message)
        DispatchQueue.main.async {
            self.message = message
        }
        /*
         if let value = extractValue(key: "text", message: message) {
             let text = value as! String
             print("ConnectionProvider.session: text = \(text)")

             // Update the model on the main thread.
             Task {
                 await MainActor.run { vm.message = text }
             }
         }
         */
    }

    // @MainActor
    func session(
        _: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        print("ConnectionProvider.session: userInfo =", userInfo)
        DispatchQueue.main.async {
            self.message = userInfo
        }
    }
}
