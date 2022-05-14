// For iOS
import SwiftUI

struct ContentView: View {
    let connectionProvider = ConnectionProvider.instance

    var body: some View {
        Button("Send to Watch") {
            connectionProvider.sendValue(key: "text", value: "from phone")
        }
        .buttonStyle(.borderedProminent)
        .onAppear {
            if !connectionProvider.session.isReachable {
                connectionProvider.session.activate()
            }
        }
    }
}
