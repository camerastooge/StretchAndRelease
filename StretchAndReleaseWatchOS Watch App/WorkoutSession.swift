//
//  WorkoutSession.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 1/30/26.
//

import Foundation
import WatchKit

@MainActor
final class StretchSession: NSObject, ObservableObject {

    @Published private(set) var isRunning = false
    private var session: WKExtendedRuntimeSession?

    /// Start the extended runtime session
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
        session?.invalidate()
        session = nil
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
        // System is about to terminate the session
        // Wrap up work, save state, schedule haptics, etc.
        print("StretchSession will expire")
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        // Session is over (expired, manually stopped, or system ended it)
        print("StretchSession invalidated: \(reason)")

        session = nil
    }
}
