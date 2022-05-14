// For iOS
import SwiftUI

struct ContentView: View {
    @StateObject private var model = Model.instance
    let connectionProvider = ConnectionProvider.instance

    var body: some View {
        VStack {
            Button("Send to Watch") {
                let format = DateFormatter()
                format.timeStyle = .medium
                format.dateStyle = .medium
                let value = "from phone, \(format.string(from: Date()))"
                connectionProvider.sendValue(key: "text", value: value)
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
