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
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    
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
                                        Text("Reps: \(repsCompleted)/\(totalReps)")
                                            .accessibilityLabel("Repetitions Completed \(repsCompleted) of \(totalReps)")
                                    }
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(!isTimerPaused ? stretchPhase.phaseColor : .gray)
                                }
                                .sensoryFeedback(.impact(intensity: haptics ? stretchPhase.phaseIntensity : 0.0), trigger: endAngle)
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
                                        Image(systemName: "playpause.fill")
                                            .frame(width: 40, height: 40)
                                            .background(!isTimerActive ? .green : .yellow)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    } else {
                                        Image(systemName: isTimerPaused || !isTimerActive ? "play.fill" : "pause.fill")
                                            .frame(width: 40, height: 40)
                                            .background(.black)
                                            .foregroundStyle(.white)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    }
                                    
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
                                    timeRemaining = totalStretch
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        updateEndAngle()
                                    }
                                } label: {
                                    if !differentiateWithoutColor {
                                        Image(systemName: "arrow.counterclockwise")
                                            .frame(width: 40, height: 40)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    } else {
                                        Image(systemName: "arrow.counterclockwise")
                                            .frame(width: 40, height: 40)
                                            .background(.black)
                                            .foregroundStyle(.white)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing)
                                .accessibilityInputLabels(["Reset", "Reset Timer"])
                                .accessibilityLabel("Reset Timer")
                                
                                Button {
                                    isShowingSettings.toggle()
                                } label: {
                                    if !differentiateWithoutColor {
                                        Image(systemName: "gear")
                                            .frame(width: 40, height: 40)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    } else {
                                        Image(systemName: "gear")
                                            .frame(width: 40, height: 40)
                                            .background(.black)
                                            .foregroundStyle(.white)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    }
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
                    TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange, audio: $audio, haptics: $haptics)
                }
                
                //receives changed settings from iOS app
                .onChange(of: connectivity.didStatusChange) {
                    totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
                    totalRest = connectivity.statusContext["rest"] as? Int ?? 5
                    totalReps = connectivity.statusContext["reps"] as? Int ?? 5
                    connectivity.didStatusChange = false
                }
                
                //sends updated settings to iOS app
                .onChange(of: didSettingsChange) {
                    sendContext(stretch: totalStretch, rest: totalRest, reps: totalReps)
                    didSettingsChange = false
                }
                
                //when user changes totalStretch in SettingsView, force timeRemaining to reset to TotalStretch
                .onChange(of: totalStretch) {
                    timeRemaining = totalStretch
                }
                
                //sets timeRemaining to totalStretch on appearance
                .onAppear {
                    timeRemaining = totalStretch
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
                                if repsCompleted < totalReps {
                                    stretchPhase = .rest
                                    SoundManager.instance.playSound(sound: .rest)
                                } else {
                                    stretchPhase = .stop
                                    timeRemaining = totalStretch
                                    withAnimation(.linear(duration: 1.0)) {
                                        updateEndAngle()
                                    }
                                    SoundManager.instance.playSound(sound: .relax)
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
                                stretchPhase = .stretch
                                timeRemaining = totalStretch
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
        }
        ._statusBarHidden()
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
    
    //sends updated settings to iPhone
    func sendContext(stretch: Int, rest: Int, reps: Int) {
        let settingsUpdate = ["stretch" : stretch, "rest" : rest, "reps" : reps]
        connectivity.setContext(to: settingsUpdate)
    }
}

#Preview {
    ContentView()
}

