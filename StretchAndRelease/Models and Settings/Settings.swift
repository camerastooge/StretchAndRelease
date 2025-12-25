//
//  Settings.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 12/18/25.
//

import SwiftUI

class Settings: ObservableObject {
    @AppStorage("stretch") public var totalStretch = 10
    @AppStorage("rest") public var totalRest = 5
    @AppStorage("reps") public var totalReps = 3
    
    @AppStorage("audio") public var audio = true
    @AppStorage("haptics") public var haptics = true
    @AppStorage("promptVolume") public var promptVolume = 1.0
    
    init(totalStretch: Int = 10, totalRest: Int = 5, totalReps: Int = 3, audio: Bool = true, haptics: Bool = true, promptVolume: Double = 1.0) {
        self.totalStretch = totalStretch
        self.totalRest = totalRest
        self.totalReps = totalReps
        self.audio = audio
        self.haptics = haptics
        self.promptVolume = promptVolume
    }
    
    static var previewData = Settings()
}
