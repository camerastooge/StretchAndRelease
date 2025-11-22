//
//  SoundManager.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import AVFoundation
import SwiftUI

@Observable
class SoundManager: NSObject {
    
    static let instance = SoundManager()
    
    var volume: Double = 1.0
    
    var player: AVAudioPlayer?
    var tickPlayer: AVAudioPlayer?
    
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
        configureSession(duck: false)
    }
    
    private func configureSession(duck: Bool) {
        let session = AVAudioSession.sharedInstance()
        var options: AVAudioSession.CategoryOptions = [.mixWithOthers]
        if duck { options.insert(.duckOthers) }
        
        do {
            try session.setCategory(.ambient, options: options)
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
    }
    
    func prepareTick(sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        do {
            tickPlayer = try AVAudioPlayer(contentsOf: url)
            tickPlayer?.prepareToPlay()
        } catch {
            print("Tick sound prep error: \(error.localizedDescription)")
        }
    }
    
    func playTick(sound: SoundOption) {
        guard let player = tickPlayer else { return }
        player.currentTime = 0.0
        player.play()
    }
    
    func playPrompt(sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        
        do {
            configureSession(duck: true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = Float(volume)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player === self.player {
            configureSession(duck: false)
            self.player = nil
        }
    }
}
