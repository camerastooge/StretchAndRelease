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
	var didSettingsChange = false
    var stretchPhase: StretchPhase = .stop
    
    func startTimer() {
        stretchPhase = .stretch
        isTimerActive = true
        isTimerPaused = false
    }
    
    func pauseTimer() {
        isTimerActive = false
        isTimerPaused = true
    }
    
    func unpauseTimer() {
        isTimerActive = true
        isTimerPaused = false
    }
    
    func stopTimer() {
        isTimerActive = false
        isTimerPaused = false
        stretchPhase = .stop
    }
}
