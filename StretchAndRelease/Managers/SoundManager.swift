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
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Audio session activation error: \(error.localizedDescription)")
            }
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

@Observable
class SoundManager: NSObject {

    static let instance = SoundManager()

    var volume: Double = 1.0

    var player: AVAudioPlayer?
    var tickPlayer: AVAudioPlayer?

    @ObservationIgnored private let session = AudioSessionController()
    @ObservationIgnored private var preparedTick: SoundOption?

    enum SoundOption: String {
        case relax = "and_relax"
        case rest = "and_rest"
        case stretch = "and_stretch"
        case tick
        case countdown = "321"
        case countdownExpanded = "321_stretch"
    }

    private override init() {
        super.init()
        session.activate()
    }

    // MARK: - Ticks

    func prepareTick(sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.prepareToPlay()
            tickPlayer = newPlayer
            preparedTick = sound
        } catch {
            print("Tick sound prep error: \(error.localizedDescription)")
        }
    }

    func playTick(sound: SoundOption) {
        // Honour the requested sound rather than replaying whatever was prepared last.
        if preparedTick != sound {
            prepareTick(sound: sound)
        }

        guard let tickPlayer = tickPlayer else { return }
        tickPlayer.currentTime = 0.0
        tickPlayer.volume = Float(volume)
        tickPlayer.play()
    }

    // MARK: - Prompts

    func playPrompt(sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }

        session.setDucking(true)

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.volume = Float(volume)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer
        } catch {
            print("Error: \(error.localizedDescription)")
            session.setDucking(false)
        }
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard player === self.player else { return }
        self.player = nil
        session.setDucking(false)
    }
}
