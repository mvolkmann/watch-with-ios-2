//
//  watch_with_ios_2App.swift
//  watch-with-ios-2 WatchKit Extension
//
//  Created by Mark Volkmann on 5/14/22.
//

import SwiftUI

@main
struct watch_with_ios_2App: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
