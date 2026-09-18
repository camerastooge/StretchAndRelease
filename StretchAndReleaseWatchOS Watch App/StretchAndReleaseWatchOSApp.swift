//
//  StretchAndReleaseWatchOSApp.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI
import SwiftData

@main
struct StretchAndReleaseWatchOS_Watch_AppApp: App {
    @State private var timer = StretchTimer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(timer)
        }
        .modelContainer(for: PlaylistItem.self, isUndoEnabled: true)
    }
}
