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
    @State private var managers = Managers()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(managers)
        }
        .modelContainer(for: PlaylistItem.self)
    }
}
