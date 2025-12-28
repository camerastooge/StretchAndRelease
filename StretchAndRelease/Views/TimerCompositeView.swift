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
    @EnvironmentObject var settings: Settings
    
    //Bindings passed from composite view
    @Binding var stretchPhase: StretchPhase
    
    //State properties
    @State private var repsCompleted = 0
    @State private var repCount = 1
    @State private var endAngle = Angle(degrees: 340)
    @State private var totalTime = 0.0
    @State private var isTimerActive = false
    @State private var isTimerPaused = false
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ZStack {
                MainArcView(stretchPhase: $stretchPhase, endAngle: $endAngle)
                    .padding(.bottom, 450)
                AnalogView(stretchPhase: $stretchPhase, timeRemaining: $settings.timeRemaining, repCount: $repCount)
            }
        }
        .padding(.top, 350)
        .scaleEffect(0.95)
        
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
                            totalTime = Double(settings.totalStretch)
                            withAnimation(.linear(duration: totalTime)) {
                                updateAngle()
                            }
                        }
                    } else {
                        if settings.audio {
                            SoundManager.instance.playPrompt(sound: .countdown)
                        }
                        DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 3.0 : .now() + 0.25) {
                            isTimerActive = true
                            isTimerPaused = false
                            withAnimation(.linear(duration: Double(settings.timeRemaining))) {
                                updateAngle()
                            }
                        }
                    }
                } else {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .stretch)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.linear(duration: totalTime)) {
                            updateAngle()
                        }
                    }
                }
            }()
                
            case .rest: {
                if !isTimerPaused {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .rest)
                    }
                    DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 1.0 : .now()) {
                        withAnimation(.linear(duration: totalTime)) {
                            updateAngle()
                        }
                    }
                } else {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .countdown)
                    }
                    DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 3.0 : .now() + 0.25) {
                        isTimerPaused = false
                        withAnimation(.linear(duration: totalTime)) {
                            updateAngle()
                        }
                    }
                }
            }()
            case .paused: {
                isTimerPaused = true
                isTimerActive = false
                updateAngle()
            }()
            case .stop:
                if repsCompleted == settings.totalReps {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .relax)
                    }
                }
                withAnimation(.linear(duration: 0.5)) {
                    isTimerActive = false
                    isTimerPaused = false
                    settings.timeRemaining = settings.totalStretch
                    updateAngle()
                }
            }
        }
    }
    
    //function to set end angle of arc
    func updateAngle() {
        switch stretchPhase {
        case .stretch: {
            endAngle = Angle(degrees: 20)
        }()
        case .rest, .stop: {
            endAngle = Angle(degrees: 340)
        }()
        case .paused: {
            endAngle = Angle(degrees: Double(settings.timeRemaining) / totalTime * 320 + 20)
        }()
        }
    }
    
    //function to handle the stretch phase of the timer
    func handleStretchPhase() {
        if settings.timeRemaining > 0 {
            settings.timeRemaining -= 1
            if settings.audio {
                SoundManager.instance.playTick(sound: .tick)
            }
        } else {
            repsCompleted += 1
            if repsCompleted < settings.totalReps {
                repCount += 1
                totalTime = Double(settings.totalRest)
                stretchPhase = .rest
            } else {
                totalTime = Double(settings.totalStretch)
                stretchPhase = .stop
            }
        }
    }
    
    //function to handle the rest phase of the timer
    func handleRestPhase() {
        if settings.timeRemaining < settings.totalRest {
            settings.timeRemaining += 1
        } else {
            totalTime = Double(settings.totalStretch)
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
        .environmentObject(Settings.previewData)
}
