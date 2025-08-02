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
    
    // State properties for settings
    @StateObject var timerSettings = TimerSettings()
    
    // state variables used across views
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var isTimerActive = false
    @State private var isTimerPaused = false
    @State private var stretchPhase: StretchPhase = .stop
    
    // state variables only used on main view
    @State private var isShowingSettings = false
    @State private var didSettingsChange = false
    @State private var isButtonPressed = false
    
    //local variable
    @State private var isResetToggled = false
    
    //Connectivity class for communication with phone
    @State private var connectivity = Connectivity()
    
    
    var body: some View {
                ZStack {
                    //Screen area for TimerActionViewWatch
                    VStack {
                        ZStack {
                            Color.gray.opacity(0)
                            
                            VStack {
                                TimerActionViewWatch(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, stretchPhase: $stretchPhase)
                                    .containerRelativeFrame(.vertical) { length, _ in
                                        length * 1
                                    }
                                
                                //Button Row
                                HStack {
                                    Button {
                                        isButtonPressed = true
                                        withAnimation {
                                            if stretchPhase == .stop {
                                                isTimerActive = true
                                                isTimerPaused = false
                                                stretchPhase = .stretch
                                                repsCompleted = 0
                                            } else if !isTimerPaused {
                                                isTimerPaused = true
                                                isTimerActive = false
                                            } else {
                                                isTimerPaused = false
                                                isTimerActive = true
                                            }
                                        }
                                        isButtonPressed = false
                                    } label: {
                                        Image(systemName: "playpause.fill")
                                            .frame(width: 40, height: 40)
                                            .background(!isTimerActive ? .green : .yellow)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                            .sensoryFeedback(.impact, trigger: isButtonPressed)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.trailing)
                                    
                                    Button {
                                        isButtonPressed = true
                                        isTimerActive = false
                                        isTimerPaused = false
                                        isResetToggled.toggle()
                                        isButtonPressed = false
                                    } label: {
                                        Image(systemName: "arrow.counterclockwise")
                                            .frame(width: 40, height: 40)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                            .sensoryFeedback(.impact, trigger: isButtonPressed)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.trailing)
                                    
                                    Button {
                                        isButtonPressed = true
                                        isShowingSettings.toggle()
                                        isButtonPressed = false
                                    } label: {
                                        Image(systemName: "gear")
                                            .frame(width: 40, height: 40)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .containerRelativeFrame(.vertical) { length, _ in
                                    length * 0.35
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $isShowingSettings) {
                    TimerSettingsViewWatch(didSettingsChange: $didSettingsChange)
                }
                .onChange(of: connectivity.didStatusChange) {
                    timerSettings.totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
                    timerSettings.totalRest = connectivity.statusContext["rest"] as? Int ?? 5
                    timerSettings.totalReps = connectivity.statusContext["reps"] as? Int ?? 5
                    connectivity.didStatusChange = false
                }
                .onChange(of: didSettingsChange) {
                    sendContext(stretch: timerSettings.totalStretch, rest: timerSettings.totalRest, reps: timerSettings.totalReps)
                    didSettingsChange = false
                }
            }
        
    func sendContext(stretch: Int, rest: Int, reps: Int) {
        let settingsUpdate = ["stretch" : stretch, "rest" : rest, "reps" : reps]
        connectivity.setContext(to: settingsUpdate)
    }
}

#Preview {
    ContentView()
}

