// For iOS
import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ConnectionViewModel.shared

    private var keys: [String] {
        Array(vm.message.keys)
    }

    private var timestamp: String {
        let format = DateFormatter()
        format.timeStyle = .medium
        format.dateStyle = .medium
        return format.string(from: Date())
    }

    var body: some View {
        VStack {
            Button("Send to Watch") {
                vm.send(message: ["timestamp": timestamp])
            }

            ForEach(keys, id: \.self) { key in
                Text("\(key) = \(stringForKey(key))")
            }
        }
        .buttonStyle(.borderedProminent)
    }

    private func stringForKey(_ key: String) -> String {
        guard let value = vm.message[key] else { return "" }
        return String(describing: value)
    }
}
