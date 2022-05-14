// For watchOS
import SwiftUI

struct ContentView: View {
    let connectionProvider = ConnectionProvider.instance
    let model = Model.instance

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
