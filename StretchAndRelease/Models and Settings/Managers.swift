//
//  Managers.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 3/10/26.
//

import SwiftUI

@Observable
class Managers {
    //properties managing timer state
    var isTimerActive = false
    var isTimerPaused = false
    var isResetToggled = false
    var didStatusChange = false
    var stretchPhase: StretchPhase = .stop
    
    func startTimer() {
        stretchPhase = .stretch
        isTimerActive = true
        isTimerPaused = false
    }
    
    //function to set end angle of arc
    func updateEndAngle(timeRemaining: Int, totalTime: Int) -> Angle {
        switch stretchPhase {
		case .stretch, .rest:
            return Angle(degrees: Double(timeRemaining) / Double(totalTime) * 320 + 20)
        case .stop:
            return Angle(degrees: 340)
        }
    }
}
