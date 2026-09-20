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
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @State private var timer = StretchTimer()

    //Built explicitly (rather than via .modelContainer(for:isUndoEnabled:))
    //so the context uses the same manager the responder chain vends.
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: PlaylistItem.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }

        container.mainContext.undoManager = AppDelegate.sharedUndoManager
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(timer)
                .background(UndoGestures())
                .background(ShakeResponder())
                .onChange(of: timer.isActive) { _, newValue in
                    UIApplication.shared.isIdleTimerDisabled = newValue
                }
        }
        .modelContainer(container)
    }
}
