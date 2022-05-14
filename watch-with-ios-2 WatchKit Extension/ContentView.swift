// For watchOS
import SwiftUI

struct ContentView: View {
    @StateObject private var model = Model.instance
    let connectionProvider = ConnectionProvider.instance

    var body: some View {
        VStack {
            Button("Send to Phone") {
                connectionProvider.sendValue(key: "text", value: "from watch")
            }
            Text("received \(model.message)")
        }
        .buttonStyle(.borderedProminent)
        .onAppear {
            if !connectionProvider.session.isReachable {
                connectionProvider.session.activate()
            }
        }
    }
}
