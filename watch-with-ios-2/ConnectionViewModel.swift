import SwiftUI
import WatchConnectivity

class ConnectionViewModel: NSObject, ObservableObject {
    @Published var message: [String: Any] = [:]

    static let shared = ConnectionViewModel()

    private let session = WCSession.default

    override private init() {
        super.init()
        session.delegate = self
        if WCSession.isSupported() {
            session.activate()
        }
    }

    func send(message: [String: Any]) {
        #if os(watchOS)
            guard WCSession.default.isCompanionAppInstalled else {
                print("ConnectionViewModel: iPhone app is not installed")
                return
            }
        #else
            guard WCSession.default.isWatchAppInstalled else {
                print("ConnectionViewModel: watch app is not installed")
                return
            }
        #endif

        session.transferUserInfo(message)
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
                "ConnectionViewModel: error \(error.localizedDescription)"
            )
        } else {
            // These print calls are just for debugging.
            // activationState values re
            // notActivated = 0, inactive = 1, activated = 2
            print(
                "ConnectionViewModel: activationState = \(activationState.rawValue)"
            )
            print(
                "ConnectionViewModel: reachable? \(session.isReachable)"
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
        // This can happen if the user switches to a new phone.
        func sessionDidDeactivate(_: WCSession) {
            print("phone/watch connection was deactivated")
            session.activate()
            session.delegate = self
        }
    #endif

    func session(
        _: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        Task {
            await MainActor.run { self.message = userInfo }
        }
    }
}
