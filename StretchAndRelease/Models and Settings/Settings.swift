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
}
