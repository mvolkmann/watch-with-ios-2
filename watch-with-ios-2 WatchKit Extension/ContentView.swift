// For watchOS
import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ConnectionViewModel.shared

    private let batteryStateMap: [WKInterfaceDeviceBatteryState: String] = [
        .charging: "charging",
        .full: "full",
        .unknown: "unknown",
        .unplugged: "unplugged",
    ]

    private var timestamp: String {
        let format = DateFormatter()
        format.timeStyle = .medium
        format.dateStyle = .medium
        return format.string(from: Date())
    }

    private let watch = WKInterfaceDevice.current()

    private var watchData: [String: Any] {
        [
            "batteryPercent": Int((watch.batteryLevel * 100).rounded()),
            "batteryState": batteryStateMap[watch.batteryState] ?? "unknown",
            "systemVersion": watch.systemVersion,
            "timestamp": timestamp
        ]
    }

    var body: some View {
        VStack {
            Button("Send to Phone") {
                vm.send(message: watchData)
            }

            let timestamp = vm.message["timestamp"] as? String ?? "unknown"
            Text("timestamp = \(timestamp)")
        }
        .buttonStyle(.borderedProminent)
        .onAppear {
            // We cannot get the battery charge percentage without this.
            watch.isBatteryMonitoringEnabled = true
        }
    }
}
