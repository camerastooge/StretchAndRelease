//
//  ContentView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

struct TimerMainView: View {
    // State properties for settings
    @State private var totalStretch = UserDefaults.standard.integer(forKey: "totalStretch")
    @State private var totalRest = UserDefaults.standard.integer(forKey: "totalRest")
    @State private var totalReps = UserDefaults.standard.integer(forKey: "totalReps")
    
    // state variables used across views
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var isTimerActive = false
    @State private var isTimerPaused = false
    @State private var stretchPhase: StretchPhase = .stop
    
    // state variables only used on main view
    @State private var isShowingSettings = false
    @State private var didSettingsChange = false
    
    //local variable
    @State private var isResetToggled = false
    
    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack {
                    //blank section placeholder
                    Section {
                        Color.red.opacity(0)
                    }
                    .frame(height: proxy.size.height * 0.1)
                    
                    //container to hold TimerActionView
                    Section {
                        ZStack {
                            Color.green.opacity(0)
                            
                            VStack {
                                TimerActionView(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
                            }
                            .padding(.vertical)
                            
                            Text("\(connectivity.statusText)")
                                .fontWeight(.bold)
                                .font(.title)
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: proxy.size.height * 0.6)
                    .padding(.bottom, 50)
                    
                    //section to hold control buttons
                    Section {
                        ZStack {
                            Color.blue.opacity(0)
                            
                            VStack {
                                Button {
                                    withAnimation {
                                        if stretchPhase == .stop {
                                            isTimerActive = true
                                            isTimerPaused = false
                                            stretchPhase = .stretch
                                        } else if !isTimerPaused {
                                            isTimerPaused = true
                                            isTimerActive = false
                                        } else {
                                            isTimerPaused = false
                                            isTimerActive = true
                                        }
                                    }
                                } label: {
                                    Text(!isTimerActive ? "START" : "PAUSE")
                                        .frame(width: 100, height: 50)
                                        .foregroundStyle(.white)
                                        .background(!isTimerActive ? .green : .yellow)
                                        .clipShape(.capsule)
                                }
                                
                                Button {
                                    isTimerActive = false
                                    isTimerPaused = false
                                    isResetToggled.toggle()
                                } label: {
                                    Text("RESET")
                                        .frame(width: 100, height: 50)
                                        .foregroundStyle(.white)
                                        .background(.red)
                                        .clipShape(.capsule)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stretch & Release")
//            .toolbar {
//                ToolbarItem {
//                    Button {
//                        isShowingSettings.toggle()
//                    } label: {
//                        Image(systemName: "gear")
//                    }
//                }
//            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange)
        }
        .onAppear {
            timeRemaining = totalStretch
        }
        .onChange(of: didSettingsChange) {
            sendContext(stretch: totalStretch, rest: totalRest, reps: totalReps)
            didSettingsChange = false
        }
        .onChange(of: connectivity.didStatusChange) {
            totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
            totalRest = connectivity.statusContext["rest"] as? Int ?? 5
            totalReps = connectivity.statusContext["reps"] as? Int ?? 5
            connectivity.didStatusChange = false
        }
            
    }
    
    func sendContext(stretch: Int, rest: Int, reps: Int) {
        let settingsUpdate = ["stretch" : stretch, "rest" : rest, "reps" : reps]
        connectivity.setContext(to: settingsUpdate)
    }
}

#Preview {
    TimerMainView()
}
