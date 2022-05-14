// For watchOS
import SwiftUI

struct ContentView: View {
    let connectionProvider = ConnectionProvider.instance

    var body: some View {
        Button("Send to Phone") {
            connectionProvider.sendValue(key: "text", value: "from watch")
        }
        .buttonStyle(.borderedProminent)
        .onAppear {
            if !connectionProvider.session.isReachable {
                connectionProvider.session.activate()
            }
        }
    }
}
