// Demo entry point. Drop this in place of the App.swift Xcode generates
// when creating a new iOS App target.
//
// All the YCFirstTime usage lives in RootView.swift — DemoApp itself is
// just the SwiftUI scene wiring.

import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
