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
    @Environment(Switches.self) var switches
    
    //Bindings passed from composite view
    @Binding var stretchPhase: StretchPhase
    
    //State properties
    @State private var repsCompleted = 0
    @State private var repCount = 1
    @State private var endAngle = Angle(degrees: 340)
    @State private var totalTime = 0.0
    @State private var timeRemaining = 0
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        VStack {
            ZStack {
                MainArcView(stretchPhase: $stretchPhase, endAngle: $endAngle)
                    .padding(.bottom, 450)
                AnalogView(stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repCount: $repCount)
            }
        }
        .padding(.top, 350)
        .scaleEffect(0.95)
        
        //this modifier runs when the timer publishes
        .onReceive(timer) { _ in
            if switches.isTimerActive {
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
                if !switches.isTimerActive {
                    if !switches.isTimerPaused {
                        if settings.audio {
                            SoundManager.instance.playPrompt(sound: .countdownExpanded)
                        }
                        DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 3.0 : .now() + 0.25) {
                            switches.isTimerActive = true
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
                            switches.isTimerActive = true
                            switches.isTimerPaused = false
                            withAnimation(.linear(duration: Double(timeRemaining))) {
                                updateAngle()
                            }
                        }
                    }
                } else {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .stretch)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        totalTime = Double(settings.totalStretch)
                        withAnimation(.linear(duration: totalTime)) {
                            updateAngle()
                        }
                    }
                }
            }()
                
            case .rest: {
                if !switches.isTimerPaused {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .rest)
                    }
                    DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 0.25 : .now()) {
                        totalTime = Double(settings.totalRest)
                        withAnimation(.linear(duration: totalTime)) {
                            updateAngle()
                        }
                    }
                } else {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .countdown)
                    }
                    DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 3.0 : .now() + 0.25) {
                        switches.isTimerPaused = false
                        withAnimation(.linear(duration: totalTime)) {
                            updateAngle()
                        }
                    }
                }
            }()
                
            case .paused: {
                switches.isTimerPaused = true
                switches.isTimerActive = false
                withAnimation(.linear(duration: 0)) {
                    updateAngle()
                }
            }()
                
            case .stop:
                if repsCompleted == settings.totalReps {
                    if settings.audio {
                        SoundManager.instance.playPrompt(sound: .relax)
                    }
                }
                withAnimation(.linear(duration: 0.5)) {
                    switches.isTimerActive = false
                    switches.isTimerPaused = false
                    timeRemaining = settings.totalStretch
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
            endAngle = Angle(degrees: Double(timeRemaining) / totalTime * 320 + 20)
        }()
        }
    }
    
    //function to handle the stretch phase of the timer
    func handleStretchPhase() {
        if timeRemaining > 0 {
            timeRemaining -= 1
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
        if timeRemaining < settings.totalRest {
            timeRemaining += 1
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
        .environment(Switches())
}
