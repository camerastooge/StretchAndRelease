//
//  StretchAndReleaseApp.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

@main
struct StretchAndReleaseApp: App {
    @StateObject private var settings = Settings()
    @State private var switches = Switches()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environment(switches)
        }
    }
}
