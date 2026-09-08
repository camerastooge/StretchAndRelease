//
//  TimerManager.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 9/7/26.
//

import Foundation

class TimerManager {
    private var duration: Int
    private var remaining: Int
    private var totalReps: Int
    private var repsRemaining: Int
    private var isPhaseComplete: Bool = false
    private var isPlaylistItemComplete: Bool? = false
    
    init(duration: Int, remaining: Int, totalReps: Int, repsRemaining: Int) {
        self.duration = duration
        self.remaining = remaining
        self.totalReps = totalReps
        self.repsRemaining = repsRemaining
    }
}

/*
 For stretch phase, receive timeRemaining value
 Subtract 1 from 
 */
