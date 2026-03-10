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
        }
        .modelContainer(for: PlaylistItem.self)
    }
}
