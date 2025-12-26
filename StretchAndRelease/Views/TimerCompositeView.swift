//
//  TimerCompositeView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 12/25/25.
//

import SwiftUI

struct TimerCompositeView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.sizeCategory) var sizeCategory
    
    //Settings
    @StateObject var settings = Settings()
    
    //Bindings passed from composite view
    @Binding var stretchPhase: StretchPhase
    
    //State properties
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var startAngle = Angle(degrees: 20)
    @State private var endAngle = Angle(degrees: 340)
    @State private var isTimerActive = false
    @State private var isTimerPaused = false
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var animationDuration: Int {
        switch stretchPhase {
        case .stretch: return settings.totalStretch
        case .rest: return settings.totalRest
        case .paused, .stop: return 0
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                MainArcView(phaseColor: stretchPhase.phaseColor,startAngle: $startAngle, endAngle: $endAngle, animationDuration: Double(animationDuration))
                    .padding(.bottom, 450)
                AnalogView(stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted)
            }
            .padding(.top, 325)
        }
        
        //this modifier runs when the timer publishes
        .onReceive(timer) { _ in
            if isTimerActive {
                if stretchPhase == .stretch {
                    handleStretchPhase()
                } else {
                    handleRestPhase()
                }
            }
        }
        
        //on change of stretchPhase, change the MainArcView & update the counter in AnalogView
        .onChange(of: stretchPhase) {
            switch stretchPhase {
            case .stretch: {
                if !isTimerActive {
                    if !isTimerPaused {
                        if settings.audio {
                            SoundManager.instance.playPrompt(sound: .countdownExpanded)
                        }
                        DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 3.0 : .now() + 0.25) {
                            isTimerActive = true
                            timeRemaining = settings.totalStretch
                            updateAngle()
                        }
                    } else {
                        if settings.audio {
                            SoundManager.instance.playPrompt(sound: .countdown)
                        }
                        DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 3.0 : .now() + 0.25) {
                            isTimerActive = true
                            isTimerPaused = false
                            updateAngle()
                        }
                    }
                } else {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .stretch)
                    }
                    updateAngle()
                }
            }()
            case .rest: {
                if !isTimerPaused {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .rest)
                    }
                    timeRemaining = settings.totalRest
                    updateAngle()
                } else {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .countdown)
                    }
                    DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 3.0 : .now() + 0.25) {
                        timeRemaining = settings.totalRest
                        isTimerPaused = false
                        updateAngle()
                    }
                }
            }()
            case .paused: {
                withAnimation(.linear(duration: 0.25)) {
                    withAnimation(.linear(duration: 0.25)) {
                        isTimerPaused = true
                        isTimerActive = false
                        updateAngle()
                    }
                }
            }()
            case .stop:
                if settings.audio {
                    SoundManager.instance.playPrompt(sound: .relax)
                }
                withAnimation(.linear(duration: 0.5)) {
                    isTimerActive = false
                    updateAngle()
                }
            }
        }
    }
    
    //function to set end angle of arc
    func updateAngle() {
        switch stretchPhase {
        case .stretch: {
            startAngle = Angle(degrees: 20)
            endAngle = Angle(degrees: 340)
        }()
        case .rest, .stop: {
            startAngle = Angle(degrees: 20)
            endAngle = Angle(degrees: 340)
        }()
        case .paused: {
            startAngle = Angle(degrees: 20)
            endAngle = Angle(degrees: 340)
        }()
        }
    }
    
    //function to handle the stretch phase of the timer
    //this should only affect the AnalogView
    func handleStretchPhase() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            if settings.audio {
                SoundManager.instance.playTick(sound: .tick)
            }
        } else {
            repsCompleted += 1
            if repsCompleted < settings.totalReps {
                stretchPhase = .rest
            } else {
                timeRemaining = settings.totalStretch
                stretchPhase = .stop
            }
        }
    }
    
    //function to handle the rest phase of the timer
    //this should only affect the AnalogView
    func handleRestPhase() {
        if timeRemaining < settings.totalRest {
            timeRemaining += 1
        } else {
            timeRemaining = settings.totalStretch
            stretchPhase = .stretch
            if settings.audio {
                SoundManager.instance.playPrompt(sound: .stretch)
            }
        }
    }
    
}

#Preview {
    @Previewable @State var stretchPhase: StretchPhase = .stop
    
    TimerCompositeView(stretchPhase: $stretchPhase)
}
