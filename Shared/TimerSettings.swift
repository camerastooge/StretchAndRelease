//
//  TimerSettings.swift
//  StretchAndRelease
//
//  Shared by the iOS and watchOS targets.
//

import Foundation
import Observation

/// The timer's user-facing settings, backed by `UserDefaults`.
///
/// `@AppStorage` is a `DynamicProperty` and only works inside a `View`, which is why
/// the timer logic used to be stuck in `TimerDisplayView` and `TimerActionViewWatch`.
/// This reads and writes the same `UserDefaults` keys, so the `@AppStorage` properties
/// still in the settings and playlist screens stay in sync with it in both directions.
@Observable
final class TimerSettings {

    static let shared = TimerSettings()

    enum Key {
        static let stretch = "stretch"
        static let rest = "rest"
        static let reps = "reps"
        static let audio = "audio"
        static let haptics = "haptics"
        static let promptVolume = "promptVolume"
        static let playlist = "playlist"
    }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var observer: NSObjectProtocol?

    /// Every getter below reads `revision`, and reading an observed property is what
    /// registers a SwiftUI view's dependency on it. Bumping `revision` therefore
    /// invalidates every view reading any setting. It is bumped by our own setters and
    /// by `UserDefaults.didChangeNotification`, which also covers writes made by the
    /// `@AppStorage` properties elsewhere in the app.
    private var revision = 0

    /// Set by a settings screen after saving, so the other device can be told.
    /// Replaces `Managers.didSettingsChange`.
    var didChange = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // One source of truth for the defaults. These used to be repeated at every
        // @AppStorage declaration, and "playlist" disagreed between files.
        defaults.register(defaults: [
            Key.stretch: 10,
            Key.rest: 5,
            Key.reps: 3,
            Key.audio: true,
            Key.haptics: true,
            Key.promptVolume: 1.0,
            Key.playlist: false
        ])

        observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: defaults,
            queue: .main
        ) { [weak self] _ in
            self?.revision &+= 1
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Durations

    var stretchDuration: Int {
        get { _ = revision; return defaults.integer(forKey: Key.stretch) }
        set {
            guard newValue != defaults.integer(forKey: Key.stretch) else { return }
            defaults.set(newValue, forKey: Key.stretch)
            revision &+= 1
        }
    }

    var restDuration: Int {
        get { _ = revision; return defaults.integer(forKey: Key.rest) }
        set {
            guard newValue != defaults.integer(forKey: Key.rest) else { return }
            defaults.set(newValue, forKey: Key.rest)
            revision &+= 1
        }
    }

    var repsToComplete: Int {
        get { _ = revision; return defaults.integer(forKey: Key.reps) }
        set {
            guard newValue != defaults.integer(forKey: Key.reps) else { return }
            defaults.set(newValue, forKey: Key.reps)
            revision &+= 1
        }
    }

    // MARK: - Feedback

    var audioEnabled: Bool {
        get { _ = revision; return defaults.bool(forKey: Key.audio) }
        set {
            guard newValue != defaults.bool(forKey: Key.audio) else { return }
            defaults.set(newValue, forKey: Key.audio)
            revision &+= 1
        }
    }

    var hapticsEnabled: Bool {
        get { _ = revision; return defaults.bool(forKey: Key.haptics) }
        set {
            guard newValue != defaults.bool(forKey: Key.haptics) else { return }
            defaults.set(newValue, forKey: Key.haptics)
            revision &+= 1
        }
    }

    var promptVolume: Double {
        get { _ = revision; return defaults.double(forKey: Key.promptVolume) }
        set {
            guard newValue != defaults.double(forKey: Key.promptVolume) else { return }
            defaults.set(newValue, forKey: Key.promptVolume)
            revision &+= 1
        }
    }

    // MARK: - Playlist

    var isPlaylistActive: Bool {
        get { _ = revision; return defaults.bool(forKey: Key.playlist) }
        set {
            guard newValue != defaults.bool(forKey: Key.playlist) else { return }
            defaults.set(newValue, forKey: Key.playlist)
            revision &+= 1
        }
    }
}
