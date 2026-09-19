//
//  WorkoutSession.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 1/30/26.
//

import Foundation
import Observation
import WatchKit

/// Keeps the app awake for the length of a run.
///
/// Without this the watch suspends the app the moment the wrist drops or the
/// screen dims: `StretchTimer`'s ticker stops being serviced, and the countdown
/// lurches forward all at once when the app is resumed. `WKBackgroundModes:
/// physical-therapy` in the Info.plist is what makes the session legal to create.
///
/// Wired up in `ContentView.onAppear` via `StretchTimer.onRunningChanged`.
@MainActor
@Observable
final class StretchSession: NSObject {

    private(set) var isRunning = false

    @ObservationIgnored private var session: WKExtendedRuntimeSession?

    /// Non-isolated so the view can build one in a `@State` initializer.
    nonisolated override init() {
        super.init()
    }

    /// Start the extended runtime session. Must be called while the app is
    /// frontmost, which it is: every caller is a user-initiated transport action.
    func start() {
        // Prevent duplicate sessions
        guard session == nil else { return }

        let newSession = WKExtendedRuntimeSession()
        newSession.delegate = self
        newSession.start()

        session = newSession
        isRunning = true
    }

    /// Stop the extended runtime session
    func stop() {
        guard let session else { return }
        session.invalidate()
        self.session = nil
        isRunning = false
    }
}

// MARK: - WKExtendedRuntimeSessionDelegate
extension StretchSession: @MainActor WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Session successfully started
        print("StretchSession started")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // The system is about to terminate the session. A physical-therapy session
        // runs for up to an hour, so a normal stretch run never gets here; if that
        // ever changes, this is where to save state or schedule a local notification.
        print("StretchSession will expire")
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        // Session is over (expired, manually stopped, or system ended it). Clear
        // both properties, or `start()` will refuse to open a replacement.
        print("StretchSession invalidated: \(reason)")

        session = nil
        isRunning = false
    }
}
