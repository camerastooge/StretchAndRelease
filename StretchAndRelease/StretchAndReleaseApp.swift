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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PlaylistItem.self)
    }
}
