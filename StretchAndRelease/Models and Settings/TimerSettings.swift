//
//  TimerSettings.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

class TimerSettings: ObservableObject {
    @AppStorage("stretch") var totalStretch = 10
    @AppStorage("rest") var totalRest = 5
    @AppStorage("reps") var totalReps = 3
    
    init(totalStretch: Int = 10, totalRest: Int = 5, totalReps: Int = 3) {
        self.totalStretch = totalStretch
        self.totalRest = totalRest
        self.totalReps = totalReps
    }
}
