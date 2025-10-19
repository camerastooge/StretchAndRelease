//
//  ContentView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.sizeCategory) var sizeCategory
    
    // Properties stored in UserDefaults
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    
    @AppStorage("firstLaunch") private var firstLaunch = true
    
    // state variables used across views
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var isTimerActive = false
    @State private var isTimerPaused = false
    @State private var stretchPhase: StretchPhase = .stop
    @State private var endAngle = Angle(degrees: 340)
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // state variables only used on main view
    @State private var isShowingSettings = false
    @State private var didSettingsChange = false
    @State private var isShowingHelp = false
    @State private var isResetToggled = false
    
    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .phone

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                Color.clear
                    .background(
                        LinearGradient(gradient: Gradient(colors: colorScheme == .dark ? [.black, .gray] : [.gray, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                VStack(spacing: 0) {
                    ZStack {
                        MainArcView(stretchPhase: $stretchPhase, haptics: $haptics, isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, endAngle: $endAngle, timeRemaining: $timeRemaining, totalReps: $totalReps, repsCompleted: $repsCompleted)
                    }
                    .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                        length * 0.9
                    }
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .layoutPriority(1)
                    
                    //Button Row
                    ZStack {
                        Color.gray.opacity(differentiateWithoutColor ? 0.0 : 0.25)
                        HStack {
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    if stretchPhase == .stop {
                                        if audio {
                                            SoundManager.instance.playPrompt(sound: .countdownExpanded)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3.0 : .now() + 0.5) {
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
                                        if audio {
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
                            .accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
                            .accessibilityLabel("Start or Pause Timer")
                            
                            Spacer()
                            
                            Button {
                                isTimerActive = false
                                isTimerPaused = false
                                repsCompleted = 0
                                stretchPhase = .stop
                                timeRemaining = totalStretch
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    updateEndAngle()
                                }
                            } label: {
                                ButtonView(buttonRoles: .reset, deviceType: .phone)
                            }
                            .accessibilityInputLabels(["Reset", "Reset Timer"])
                            .accessibilityLabel("Reset Timer")
                            
                            Spacer()
                        }
                        .padding([.horizontal, .vertical])
                    }
                }
            }
            .navigationTitle("Stretch & Release")
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowingHelp.toggle()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.blue)
                                .glassEffect()
                        } else {
                            Image(systemName: "questionmark.circle.fill")
                        }
                    }
                }
                
                if #available(iOS 26.0, *) {
                    ToolbarSpacer()
                }
                
                ToolbarItem {
                    Button {
                        isShowingSettings.toggle()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "gear")
                                .foregroundStyle(.blue)
                                .glassEffect()
                        } else {
                            Image(systemName: "gear")
                        }
                    }
                    .accessibilityInputLabels(["Settings"])
                    .accessibilityLabel("Show Settings")
                }
            }

        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange, audio: $audio, haptics: $haptics)
        }
        .sheet(isPresented: $isShowingHelp) {
            MainHelpScreenView()
                .presentationDetents([.medium])
        }
        
        
        //receives changed settings from Apple Watch app
        .onChange(of: connectivity.didStatusChange) {
            totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
            totalRest = connectivity.statusContext["rest"] as? Int ?? 5
            totalReps = connectivity.statusContext["reps"] as? Int ?? 5
            connectivity.didStatusChange = false
        }
        
        //when settings change, updates main display and sends updated settings to Apple Watch app
        .onChange(of: didSettingsChange) {
            stretchPhase = .stop
            isTimerActive = false
            isTimerPaused = false
            endAngle = Angle(degrees: 340)
            timeRemaining = totalStretch
            sendContext(stretch: totalStretch, rest: totalRest, reps: totalReps)
            didSettingsChange = false
        }
        
        //when user changes totalStretch in SettingsView, or app launches and loads totalStretch from AppStorage, force timeRemaining to reset to TotalStretch
        .onChange(of: totalStretch, initial: true) {
            timeRemaining = totalStretch
            if firstLaunch { isShowingHelp.toggle() }
            firstLaunch = false
        }
        
        //prep tick audio player when app launches
        .onAppear {
            SoundManager.instance.prepareTick(sound: .tick)
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
                        if audio {
                            SoundManager.instance.playTick(sound: .tick)
                        }
                    } else {
                        repsCompleted += 1
                        if repsCompleted < totalReps {
                            withAnimation {
                                stretchPhase = .rest
                            }
                            if audio {
                                SoundManager.instance.playPrompt(sound: .rest)
                            }
                        } else {
                            timeRemaining = totalStretch
                            withAnimation(.linear(duration: 0.5)) {
                                stretchPhase = .stop
                                updateEndAngle()
                            }
                            if audio {
                                SoundManager.instance.playPrompt(sound: .relax)
                            }
                        }
                    }
                }()
                    
                case .rest: return {
                    if timeRemaining < totalRest {
                        timeRemaining += 1
                        withAnimation(.linear(duration: 1.0)) {
                            updateEndAngle()
                        }
                    } else {
                        timeRemaining = totalStretch
                        withAnimation {
                            stretchPhase = .stretch
                        }
                        if audio {
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
    
    //function to set end angle of arc
    func updateEndAngle() {
        switch stretchPhase {
        case .stretch:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(totalStretch) * 320 + 20)
        case .rest:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(totalRest) * 320 + 20)
        case .stop:
            endAngle = Angle(degrees: 340)
        }
    }
    
    //function sends updated settings to Apple Watch
    func sendContext(stretch: Int, rest: Int, reps: Int) {
        let settingsUpdate = ["stretch" : stretch, "rest" : rest, "reps" : reps]
        connectivity.setContext(to: settingsUpdate)
    }
}
        


#Preview {
    ContentView()
}
