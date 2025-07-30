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
    @State private var totalStretch = UserDefaults.standard.integer(forKey: "totalStretch")
    @State private var totalRest = UserDefaults.standard.integer(forKey: "totalRest")
    @State private var totalReps = UserDefaults.standard.integer(forKey: "totalReps")
    
    // state variables used across views
    @State private var timeRemaining: Int = 1
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
    
    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                    //space for TimerActionView
                    VStack(spacing: 0) {
                        ZStack {
                            Color.green.opacity(0)
                            TimerActionView(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
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
                                
                                Button {
                                    isButtonPressed = true
                                    isTimerActive = false
                                    isTimerPaused = false
                                    repsCompleted = 0
                                    isResetToggled.toggle()
                                    isButtonPressed = false
                                } label: {
                                    Text("RESET")
                                        .frame(width: 100, height: 50)
                                        .foregroundStyle(.white)
                                        .background(.red)
                                        .clipShape(.capsule)
                                        .shadow(color: colorScheme == .light ? .black.opacity(0.25) : .white.opacity(0.5), radius: 0.8, x: 2, y: 2)
                                        .sensoryFeedback(.impact, trigger: isButtonPressed)
                                }
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
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange)
            }
            .onAppear {
                if totalStretch == 0 { totalStretch = 10 }
                if totalRest == 0 { totalRest = 4 }
                if totalReps == 0 { totalReps = 4 }
                timeRemaining = totalStretch
            }
            .onChange(of: connectivity.didStatusChange) {
                totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
                totalRest = connectivity.statusContext["rest"] as? Int ?? 5
                totalReps = connectivity.statusContext["reps"] as? Int ?? 5
                connectivity.didStatusChange = false
            }
            .onChange(of: didSettingsChange) {
                sendContext(stretch: totalStretch, rest: totalRest, reps: totalReps)
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
