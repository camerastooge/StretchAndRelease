//
//  SoundManager.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import Foundation
import AVFoundation

class SoundManager {
    
    static let instance = SoundManager()
    
    var player: AVAudioPlayer?
    
    enum SoundOption: String {
        case relax = "and_relax"
        case rest = "and_rest"
        case stretch = "and_stretch"
        case tick
        case countdown = "321"
        case countdownExpanded = "321_stretch"
    }
    
    private init() {

    }
    
    func playSound(sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
