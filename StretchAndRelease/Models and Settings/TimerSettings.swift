//
//  TimerSettings.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import Foundation

class TimerSettings: ObservableObject {
    @Published var totalStretch = 10.0
    @Published var totalRest = 5.0
    @Published var totalReps = 3
    
    init(totalStretch: Double = 10.0, totalRest: Double = 5.0, totalReps: Int = 3) {
        self.totalStretch = totalStretch
        self.totalRest = totalRest
        self.totalReps = totalReps
    }
}
