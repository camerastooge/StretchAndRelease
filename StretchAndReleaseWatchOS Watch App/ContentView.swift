//
//  ContentView.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI

struct ContentView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    // Properties stored in UserDefaults
    @StateObject var settings = Settings()
    
    // state variables used across views
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var isTimerActive = false
    @State private var isTimerPaused = false
    @State private var stretchPhase: StretchPhase = .stop
    @State private var endAngle = Angle(degrees: 340)
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // state variables only used on main view
    @State private var isShowingSettings = false
    @State private var didSettingsChange = false
    
    //Connectivity class for communication with phone
    @State private var connectivity = Connectivity()
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .watch
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                //Screen area for TimerActionViewWatch
                VStack {
                    ZStack {
                        Color.gray.opacity(0)
                        
                        VStack {
                            Color.gray.opacity(0)
                            
                            ZStack {
                                Color.gray.opacity(0)
                                
                                ZStack {
                                    Arc(endAngle: endAngle)
                                        .stroke(stretchPhase.phaseColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                        .rotationEffect(Angle(degrees: 90))
                                    
                                    VStack {
                                        Text("\(String(format: "%02d", Int(timeRemaining)))")
                                            .font(.largeTitle)
                                            .kerning(2)
                                            .contentTransition(.numericText(countsDown: true))
                                            .accessibilityLabel("\(timeRemaining) seconds remaining")
                                        Text(!isTimerPaused ? stretchPhase.phaseText : "PAUSED")
                                            .scaleEffect(0.75)
                                            .accessibilityLabel(!isTimerPaused ? stretchPhase.phaseText : "WORKOUT PAUSED")
                                        Text("Reps: \(repsCompleted)/\(settings.totalReps)")
                                            .accessibilityLabel("Repetitions Completed \(repsCompleted) of \(settings.totalReps)")
                                    }
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(!isTimerPaused ? stretchPhase.phaseColor : .gray)
                                }
                                .sensoryFeedback(.impact(intensity: settings.haptics ? stretchPhase.phaseIntensity : 0.0), trigger: endAngle)
                            }
                            .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                                length * 0.9
                            }
                            .containerRelativeFrame(.vertical, alignment: .center) { length, _ in
                                length * 0.96
                            }
                            
                            //Button Row
                            HStack {
                                Button {
                                    withAnimation {
                                        if stretchPhase == .stop {
                                            if settings.audio {
                                                SoundManager.instance.playPrompt(sound: .countdownExpanded)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                withAnimation(.linear(duration: 0.25)) {
                                                    isTimerActive = true
                                                    isTimerPaused = false
                                                    stretchPhase = .stretch
                                                    repsCompleted = 0
                                                }
                                            }
                                        } else if !isTimerPaused {
                                            isTimerPaused = true
                                            isTimerActive = false
                                        } else {
                                            if settings.audio {
                                                SoundManager.instance.playPrompt(sound: .countdownExpanded)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                withAnimation(.linear(duration: 0.25)) {
                                                    isTimerPaused = false
                                                    isTimerActive = true
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    ButtonView(buttonRoles: !isTimerActive ? .play : .pause, deviceType: deviceType)
                                    
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing)
                                .accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
                                .accessibilityLabel("Start or Pause Timer")
                                
                                Button {
                                    isTimerActive = false
                                    isTimerPaused = false
                                    repsCompleted = 0
                                    stretchPhase = .stop
                                    timeRemaining = settings.totalStretch
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        updateEndAngle()
                                    }
                                } label: {
                                    ButtonView(buttonRoles: .reset, deviceType: deviceType)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing)
                                .accessibilityInputLabels(["Reset", "Reset Timer"])
                                .accessibilityLabel("Reset Timer")
                                
                                Button {
                                    isShowingSettings.toggle()
                                } label: {
                                    ButtonView(buttonRoles: .settings, deviceType: deviceType)
                                }
                                .buttonStyle(.plain)
                                .accessibilityInputLabels(["Settings"])
                                .accessibilityLabel("Show Settings")
                            }
                            .dynamicTypeSize(DynamicTypeSize.xxxLarge)
                            .containerRelativeFrame(.vertical) { length, _ in
                                length * 0.35
                            }                    }
                    }
                }
                .sheet(isPresented: $isShowingSettings) {
                    TimerSettingsViewWatch(didSettingsChange: $didSettingsChange)
                }
                
                //stops and resets tiner when settings view is toggled
                .onChange(of: isShowingSettings) {
                    withAnimation(.smooth(duration: 0.25)) {
                        stretchPhase = .stop
                        timeRemaining = settings.totalStretch
                        repsCompleted = 0
                        endAngle = Angle(degrees: 340)
                    }
                }
                
                //receives changed settings from iOS app
                .onChange(of: connectivity.didStatusChange) {
                    settings.totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
                    settings.totalRest = connectivity.statusContext["rest"] as? Int ?? 5
                    settings.totalReps = connectivity.statusContext["reps"] as? Int ?? 5
                    connectivity.didStatusChange = false
                }
                
                //sends updated settings to iOS app
                .onChange(of: didSettingsChange) {
                    sendContext(stretch: settings.totalStretch, rest: settings.totalRest, reps: settings.totalReps)
                    didSettingsChange = false
                }
                
                //when user changes totalStretch in SettingsView, force timeRemaining to reset to TotalStretch
                .onChange(of: settings.totalStretch) {
                    timeRemaining = settings.totalStretch
                }
                
                //sets timeRemaining to totalStretch on appearance
                .onAppear {
                    timeRemaining = settings.totalStretch
                }
                
                //prep tick audio player when app launches
                .onAppear() {
                    SoundManager.instance.prepareTick(sound: .tick)
                    SoundManager.instance.volume = settings.promptVolume
                }
                
                //this modifier runs when the timer publishes
                .onReceive(timer) { _ in
                    if isTimerActive && !isTimerPaused {
                        switch stretchPhase {
                        case .stretch: return {
                            if timeRemaining > 0 {
                                timeRemaining -= 1
                                withAnimation(.linear(duration: 1.0)) {
                                    updateEndAngle()
                                }
                                if settings.audio {
                                    SoundManager.instance.playTick(sound: .tick)
                                }
                            } else {
                                repsCompleted += 1
                                if repsCompleted < settings.totalReps {
                                    stretchPhase = .rest
                                    if settings.audio {
                                        SoundManager.instance.playPrompt(sound: .rest)
                                    }
                                } else {
                                    stretchPhase = .stop
                                    timeRemaining = settings.totalStretch
                                    withAnimation(.linear(duration: 1.0)) {
                                        updateEndAngle()
                                    }
                                    if settings.audio {
                                        SoundManager.instance.playPrompt(sound: .relax)
                                    }
                                }
                            }
                        }()
                            
                        case .rest: return {
                            if timeRemaining < settings.totalRest {
                                timeRemaining += 1
                                withAnimation(.linear(duration: 1.0)) {
                                    updateEndAngle()
                                }
                            } else {
                                stretchPhase = .stretch
                                timeRemaining = settings.totalStretch
                                if settings.audio {
                                    SoundManager.instance.playPrompt(sound: .stretch)
                                }
                            }
                        }()
                            
                        case .stop: return {
                            isTimerActive = false
                        }()
                        }
                    }
                }
            }
        }
        ._statusBarHidden()
    }
    
    //function to set end angle of arc
    func updateEndAngle() {
        switch stretchPhase {
        case .stretch, .rest:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(settings.totalStretch) * 320 + 20)
        case .stop:
            endAngle = Angle(degrees: 340)
        }
    }
    
    //sends updated settings to iPhone
    func sendContext(stretch: Int, rest: Int, reps: Int) {
        let settingsUpdate = ["stretch" : stretch, "rest" : rest, "reps" : reps]
        connectivity.setContext(to: settingsUpdate)
    }
}

#Preview {
    ContentView()
}

