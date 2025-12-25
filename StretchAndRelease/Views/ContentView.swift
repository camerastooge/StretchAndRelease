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
    
    // Settings stored in AppStorage
    @StateObject var settings = Settings()
    
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
    @State private var buttonRoles: ButtonRoles = .play
    @State private var deviceType: DeviceType = .phone

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                Color.clear
                    .background(
                        LinearGradient(gradient: Gradient(colors: colorScheme == .dark ? [.black, .gray] : [.gray, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                VStack(spacing: 0) {
                    ZStack {
                        VStack {
                            //need to put countdown display here
                            TimerCompositeView(stretchPhase: $stretchPhase, endAngle: $endAngle, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted)
                        }
                        .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                            length * 0.85
                        }
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .layoutPriority(1)
                    }
                        
                        //Button Row
                        ButtonRowView(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, endAngle: $endAngle, deviceType: $deviceType)
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
                SettingsView(didSettingsChange: $didSettingsChange)
            }
            
            .sheet(isPresented: $isShowingHelp) {
                MainHelpScreenView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            
            //stops and resets tiner when either settings or help views are toggled
            .onChange(of: isShowingSettings || isShowingHelp) {
                withAnimation(.smooth(duration: 0.25)) {
                    stretchPhase = .stop
                    timeRemaining = settings.totalStretch
                    repsCompleted = 0
                    endAngle = Angle(degrees: 340)
                }
            }
            
            //receives changed settings from Apple Watch app
            .onChange(of: connectivity.didStatusChange) {
                settings.totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
                settings.totalRest = connectivity.statusContext["rest"] as? Int ?? 5
                settings.totalReps = connectivity.statusContext["reps"] as? Int ?? 5
                connectivity.didStatusChange = false
            }
            
            //when settings change, updates main display and sends updated settings to Apple Watch app
            .onChange(of: didSettingsChange) {
                stretchPhase = .stop
                isTimerActive = false
                isTimerPaused = false
                endAngle = Angle(degrees: 340)
                timeRemaining = settings.totalStretch
                sendContext(stretch: settings.totalStretch, rest: settings.totalRest, reps: settings.totalReps)
                didSettingsChange = false
            }
            
            //when user changes totalStretch in SettingsView, or app launches and loads totalStretch from AppStorage, force timeRemaining to reset to TotalStretch
            .onChange(of: settings.totalStretch, initial: true) {
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
                    case .stretch: handleStretchPhase()
                        
                    case .rest: handleRestPhase()
                        
                    case .paused: isTimerActive = false
                        
                    case .stop: isTimerActive = false
                    }
                }
            }
        }
    
    //function to set end angle of arc
    func updateEndAngle() {
        switch stretchPhase {
        case .stretch, .rest:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(settings.totalStretch) * 320 + 20)
        case .stop, .paused:
            endAngle = Angle(degrees: 340)
        }
    }
    
    //function sends updated settings to Apple Watch
    func sendContext(stretch: Int, rest: Int, reps: Int) {
        let settingsUpdate = ["stretch" : stretch, "rest" : rest, "reps" : reps]
        connectivity.setContext(to: settingsUpdate)
    }
    
    //function to handle the stretch phase of the timer
    func handleStretchPhase() {
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
                withAnimation {
                    stretchPhase = .rest
                }
                if settings.audio {
                    SoundManager.instance.playPrompt(sound: .rest)
                }
            } else {
                timeRemaining = settings.totalStretch
                withAnimation(.linear(duration: 0.5)) {
                    stretchPhase = .stop
                    updateEndAngle()
                }
                if settings.audio {
                    SoundManager.instance.playPrompt(sound: .relax)
                }
            }
        }
    }
    
    //function to handle the rest phase of the timer
    func handleRestPhase() {
        if timeRemaining < settings.totalRest {
            timeRemaining += 1
            withAnimation(.linear(duration: 1.0)) {
                updateEndAngle()
            }
        } else {
            timeRemaining = settings.totalStretch
            withAnimation {
                stretchPhase = .stretch
            }
            if settings.audio {
                SoundManager.instance.playPrompt(sound: .stretch)
            }
        }
    }
}
        


#Preview {
    ContentView()
}
