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
    
    // State properties for settings
    @StateObject var timerSettings = TimerSettings()
    
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
    
    //local variable
    @State private var isResetToggled = false
    @State private var didStretchStart = false
    
    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    ZStack {
                        Color.green.opacity(0)
                        
                        Arc(endAngle: endAngle)
                                .stroke(differentiateWithoutColor ? .black : stretchPhase.phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                                .rotationEffect(Angle(degrees: 90))
                                .padding(.bottom)
                        
                        VStack {
                            Text("\(String(format: "%02d", Int(timeRemaining)))")
                                .kerning(2)
                                .contentTransition(.numericText(countsDown: true))
                                .accessibilityLabel("\(timeRemaining) seconds remaining")
                            Text(!isTimerPaused ? stretchPhase.phaseText : "PAUSED")
                                .scaleEffect(0.75)
                                .accessibilityLabel(!isTimerPaused ? stretchPhase.phaseText : "WORKOUT PAUSED")
                            Text("Reps: \(repsCompleted)/\(timerSettings.totalReps)")
                                .accessibilityLabel("Repetitions Completed \(repsCompleted) of \(timerSettings.totalReps)")
                        }
                        .font(.largeTitle)
                        .foregroundStyle(!isTimerPaused ? differentiateWithoutColor ? .black : stretchPhase.phaseColor : .gray)
                        .fontWeight(.bold)
                        .sensoryFeedback(.impact(intensity: stretchPhase.phaseIntensity), trigger: endAngle)
                        .containerRelativeFrame(.vertical, alignment: .bottom) { length, _ in
                            length / 1.15
                        }
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
                                        SoundManager.instance.playSound(sound: .countdownExpanded)
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
                                        SoundManager.instance.playSound(sound: .countdownExpanded)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation(.linear(duration: 0.25)) {
                                                isTimerPaused = false
                                                isTimerActive = true
                                            }
                                        }
                                    }
                                }
                            } label: {
                                if !differentiateWithoutColor {
                                    Image(systemName: !isTimerActive ? "play.fill" : "pause.fill")
                                        .frame(width: 85, height: 50)
                                        .foregroundStyle(.white)
                                        .background(!isTimerActive ? .green : .yellow)
                                        .clipShape(.capsule)
                                        .shadow(color: colorScheme == .light ? .black.opacity(0.25) : .white.opacity(0.5), radius: 0.8, x: 2, y: 2)
                                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                                } else {
                                    Image(systemName: !isTimerActive ? "play.fill" : "pause.fill")
                                        .frame(width: 75, height: 50)
                                        .foregroundStyle(.black)
                                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                                }
                            }
                            .accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
                            .accessibilityLabel("Start or Pause Timer")
                            
                            Spacer()
                            
                            Button {
                                isTimerActive = false
                                isTimerPaused = false
                                repsCompleted = 0
                                stretchPhase = .stop
                                timeRemaining = timerSettings.totalStretch
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    updateEndAngle()
                                }
                            } label: {
                                if !differentiateWithoutColor {
                                    Image(systemName: "arrow.counterclockwise")
                                        .frame(width: 75, height: 50)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .background(.red)
                                        .clipShape(.capsule)
                                        .shadow(color: colorScheme == .light ? .black.opacity(0.25) : .white.opacity(0.5), radius: 0.8, x: 2, y: 2)
                                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                                } else {
                                    Image(systemName: "arrow.counterclockwise")
                                        .frame(width: 75, height: 50)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.black)
                                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                                }
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
                        isShowingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                    .accessibilityInputLabels(["Settings"])
                    .accessibilityLabel("Show Settings")
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(didSettingsChange: $didSettingsChange)
                .environmentObject(timerSettings)
        }
        
        //receives changed settings from Apple Watch app
        .onChange(of: connectivity.didStatusChange) {
            timerSettings.totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
            timerSettings.totalRest = connectivity.statusContext["rest"] as? Int ?? 5
            timerSettings.totalReps = connectivity.statusContext["reps"] as? Int ?? 5
            connectivity.didStatusChange = false
        }
        
        //when settings change, updates main display and sends updated settings to Apple Watch app
        .onChange(of: didSettingsChange) {
            stretchPhase = .stop
            isTimerActive = false
            isTimerPaused = false
            endAngle = Angle(degrees: 340)
            timeRemaining = timerSettings.totalStretch
            sendContext(stretch: timerSettings.totalStretch, rest: timerSettings.totalRest, reps: timerSettings.totalReps)
            didSettingsChange = false
        }
        
        //sets timeRemaining to totalStretch on appearance
        .onAppear {
            timeRemaining = timerSettings.totalStretch
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
                        SoundManager.instance.playSound(sound: .tick)
                    } else {
                        repsCompleted += 1
                        if repsCompleted < timerSettings.totalReps {
                            stretchPhase = .rest
                            SoundManager.instance.playSound(sound: .rest)
                        } else {
                            stretchPhase = .stop
                            timeRemaining = timerSettings.totalStretch
                            withAnimation(.linear(duration: 1.0)) {
                                updateEndAngle()
                            }
                            SoundManager.instance.playSound(sound: .relax)
                        }
                    }
                }()
                    
                case .rest: return {
                    if timeRemaining < timerSettings.totalRest {
                        timeRemaining += 1
                        withAnimation(.linear(duration: 1.0)) {
                            updateEndAngle()
                        }
                    } else {
                        stretchPhase = .stretch
                        timeRemaining = timerSettings.totalStretch
                        SoundManager.instance.playSound(sound: .stretch)
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
            endAngle = Angle(degrees: Double(timeRemaining) / Double(timerSettings.totalStretch) * 320 + 20)
        case .rest:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(timerSettings.totalRest) * 320 + 20)
        case .stop:
            endAngle = Angle(degrees: 340)
        }
    }
    
    //function sends updated settings to Apple Watch
    func sendContext(stretch: Int, rest: Int, reps: Int) {
        let settingsUpdate = ["stretch" : stretch, "rest" : rest, "reps" : reps]
        connectivity.setContext(to: settingsUpdate)
    }
    
    //func to trigger timer?
    func timerStart() {
        
    }
}
        

    
    #Preview {
        ContentView()
    }
