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
    @State private var didStretchStart = false
    
    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                    //space for TimerActionView
                    VStack(spacing: 0) {
                        ZStack {
                            Color.green.opacity(0)
                            TimerActionView(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, stretchPhase: $stretchPhase)
                                .padding(.bottom, 50)
                        }
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .layoutPriority(1)
                        
                        ZStack {
                            Color.gray.opacity(0.15)
                            HStack {
                                Button {
                                    withAnimation {
                                        isButtonPressed = true
                                        if stretchPhase == .stop {
                                            isTimerActive = true
                                            isTimerPaused = false
                                            stretchPhase = .stretch
                                            repsCompleted = 0
                                            didStretchStart = true
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
                                    Text(!isTimerActive ? "START" : "PAUSE")
                                        .frame(width: 100, height: 50)
                                        .foregroundStyle(.white)
                                        .background(!isTimerActive ? .green : .yellow)
                                        .clipShape(.capsule)
                                        .shadow(color: colorScheme == .light ? .black.opacity(0.25) : .white.opacity(0.5), radius: 0.8, x: 2, y: 2)
                                        .sensoryFeedback(.impact, trigger: isButtonPressed)
                                }
                                .accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
                                .accessibilityLabel("Start or Pause Timer")
                                
                                Button {
                                    isButtonPressed = true
                                    isTimerActive = false
                                    isTimerPaused = false
                                    repsCompleted = 0
                                    isResetToggled.toggle()
<<<<<<< HEAD
<<<<<<< HEAD
                                    stretchPhase = .stop
=======
                                    isButtonPressed = false
>>>>>>> parent of 4a371c6 (removed haptics from button presses)
=======
                                    isButtonPressed = false
>>>>>>> parent of 4a371c6 (removed haptics from button presses)
                                } label: {
                                    Text("RESET")
                                        .frame(width: 100, height: 50)
                                        .foregroundStyle(.white)
                                        .background(.red)
                                        .clipShape(.capsule)
                                        .shadow(color: colorScheme == .light ? .black.opacity(0.25) : .white.opacity(0.5), radius: 0.8, x: 2, y: 2)
                                        .sensoryFeedback(.impact, trigger: isButtonPressed)
                                }
                                .accessibilityInputLabels(["Reset", "Reset Timer"])
                                .accessibilityLabel("Reset Timer")
                            }
                            .padding(.vertical)
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
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(didSettingsChange: $didSettingsChange)
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
        //sets timeRemaining to totalStretch on appearance
            .onAppear {
                timeRemaining = timerSettings.totalStretch
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
