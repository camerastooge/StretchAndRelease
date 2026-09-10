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
    @State private var managers = Managers()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(managers)
                .onChange(of: managers.isTimerActive) { _, newvalue in
                    UIApplication.shared.isIdleTimerDisabled = newvalue
                }
        }
        .modelContainer(for: PlaylistItem.self)
    }
}
