//
//  SoundManager.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import AVFoundation
import SwiftUI

/// Owns every AVAudioSession call.
///
/// `setCategory` and `setActive` can block for tens of milliseconds, and iOS logs
/// a warning when they run on the main thread while the session is already active,
/// so all of it is hopped onto a private serial queue. Every mutable property below
/// is confined to `queue`, which is what makes the `@unchecked Sendable` honest.
private final class AudioSessionController: @unchecked Sendable {

    private let queue = DispatchQueue(label: "com.LucasBarker.StretchAndRelease.audioSession")

    /// `nil` until the category has been set for the first time.
    private var isDucking: Bool?

    /// Sets the category and activates the session. Called once, at launch.
    func activate() {
        queue.async {
            self.applyCategory(duck: false)
            // `setActive` logs a warning recommending the async activate/deactivate API
            // regardless of calling thread, so prefer it where it exists.
            //
            // `activate(options:completionHandler:)` is watchOS-only through the iOS 26 SDK:
            // it is declared `@available(iOS, unavailable)` there. Unavailability is a hard
            // compile-time error that an `#available` version check cannot unlock, so this
            // has to split by platform at compile time rather than by version at runtime.
            #if os(watchOS)
            AVAudioSession.sharedInstance().activate(options: []) { _, error in
                if let error {
                    print("Audio session activation error: \(error.localizedDescription)")
                }
            }
            #else
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Audio session activation error: \(error.localizedDescription)")
            }
            #endif
        }
    }

    /// Starts or stops ducking other audio. No-ops when already in that state.
    func setDucking(_ duck: Bool) {
        queue.async {
            self.applyCategory(duck: duck)
        }
    }

    private func applyCategory(duck: Bool) {
        guard isDucking != duck else { return }

        var options: AVAudioSession.CategoryOptions = [.mixWithOthers]
        if duck { options.insert(.duckOthers) }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: options)
            isDucking = duck
        } catch {
            print("Audio session category error: \(error.localizedDescription)")
        }
    }
}

/// Owns the `AVAudioPlayer`s.
///
/// Everything here is confined to `queue` and every entry point is `async`, so no
/// caller ever waits for the audio stack. That matters much more than it looks:
/// `AVAudioPlayer.play()` is effectively free on iOS, but on watchOS it has to
/// negotiate with the audio server and, if the route is Bluetooth or the speaker
/// has gone idle, can take hundreds of milliseconds. The timer calls `playTick`
/// once a second from the main actor, so anything that blocks the caller lands
/// squarely in the middle of the arc animation and drops frames.
private final class PlaybackEngine: NSObject, @unchecked Sendable {

    private let queue = DispatchQueue(label: "com.LucasBarker.StretchAndRelease.playback", qos: .userInitiated)
    private let session = AudioSessionController()

    // Queue-confined. Nothing outside `queue` may touch these.
    private var tickPlayer: AVAudioPlayer?
    private var preparedTick: String?
    private var promptPlayer: AVAudioPlayer?

    func activateSession() {
        session.activate()
    }

    func prepareTick(url: URL, key: String) {
        queue.async { self.loadTick(url: url, key: key) }
    }

    func playTick(url: URL, key: String, volume: Double) {
        queue.async {
            // Honour the requested sound rather than replaying whatever was prepared last.
            self.loadTick(url: url, key: key)

            guard let player = self.tickPlayer else { return }
            player.volume = Float(volume)
            player.currentTime = 0
            player.play()
        }
    }

    func playPrompt(url: URL, volume: Double) {
        session.setDucking(true)

        queue.async {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = Float(volume)
                player.delegate = self
                player.prepareToPlay()
                player.play()
                self.promptPlayer = player
            } catch {
                print("Prompt playback error: \(error.localizedDescription)")
                self.session.setDucking(false)
            }
        }
    }

    /// Must be called on `queue`.
    private func loadTick(url: URL, key: String) {
        guard preparedTick != key else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            tickPlayer = player
            preparedTick = key
        } catch {
            print("Tick sound prep error: \(error.localizedDescription)")
            tickPlayer = nil
            preparedTick = nil
        }
    }
}

extension PlaybackEngine: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        queue.async {
            guard player === self.promptPlayer else { return }
            self.promptPlayer = nil
            self.session.setDucking(false)
        }
    }
}

@Observable
final class SoundManager {

    static let instance = SoundManager()

    /// Read and written from the main actor by the settings screens and by
    /// `StretchTimer.settingsDidChange()`. Snapshotted at each call below, so the
    /// playback queue never reads it.
    var volume: Double = 1.0

    @ObservationIgnored private let engine = PlaybackEngine()

    enum SoundOption: String {
        case relax = "and_relax"
        case rest = "and_rest"
        case stretch = "and_stretch"
        case tick
        case countdown = "321"
        case countdownExpanded = "321_stretch"
    }

    private init() {
        engine.activateSession()
    }

    private func url(for sound: SoundOption) -> URL? {
        Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3")
    }

    // MARK: - Ticks

    /// Warms the tick player. Returns immediately; the decode happens on the
    /// playback queue.
    func prepareTick(sound: SoundOption) {
        guard let url = url(for: sound) else { return }
        engine.prepareTick(url: url, key: sound.rawValue)
    }

    /// Fire and forget. Called once per second from `StretchTimer.tick()` on the
    /// main actor, so it must never wait on the audio stack.
    func playTick(sound: SoundOption) {
        guard let url = url(for: sound) else { return }
        engine.playTick(url: url, key: sound.rawValue, volume: volume)
    }

    // MARK: - Prompts

    /// Fire and forget, for the same reason as `playTick`. Building and priming an
    /// `AVAudioPlayer` is the expensive half of this, and it now happens entirely
    /// off the caller's thread.
    func playPrompt(sound: SoundOption) {
        guard let url = url(for: sound) else { return }
        engine.playPrompt(url: url, volume: volume)
    }
}
