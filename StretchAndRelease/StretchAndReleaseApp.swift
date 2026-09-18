//
//  StretchAndReleaseApp.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI
import SwiftData

@main
struct StretchAndReleaseApp: App {
    @State private var timer = StretchTimer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(timer)
                .onChange(of: timer.isActive) { _, newValue in
                    UIApplication.shared.isIdleTimerDisabled = newValue
                }
        }
        .modelContainer(for: PlaylistItem.self, isUndoEnabled: true)
    }
}
