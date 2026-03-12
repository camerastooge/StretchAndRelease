//
//  Managers.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 3/10/26.
//

import Foundation

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
    
    func stopTimer() {
        stretchPhase = .stop
        isTimerActive = false
        isTimerPaused = false
    }
}
