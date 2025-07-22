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
    
    //Connectivity class for communication with phone
    @State private var connectivity = Connectivity()
    
    
    var body: some View {
                ZStack {
                    //Screen area for TimerActionViewWatch
                    VStack {
                        ZStack {
                            Color.gray.opacity(0)
                            
                            VStack {
                            TimerActionViewWatch(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
                                    .containerRelativeFrame(.vertical) { length, _ in
                                        length * 1
                                    }
                                
                                //Button Row
                                HStack {
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
                                        Image(systemName: "playpause.fill")
                                            .frame(width: 40, height: 40)
                                            .background(!isTimerActive ? .green : .yellow)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.trailing)
                                    
                                    Button {
                                        isTimerActive = false
                                        isTimerPaused = false
                                        isResetToggled.toggle()
                                    } label: {
                                        Image(systemName: "arrow.counterclockwise")
                                            .frame(width: 40, height: 40)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .scaleEffect(0.85)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.trailing)
                                    
                                    Button {
                                        isShowingSettings.toggle()
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
                    
                    Text("\(connectivity.statusText)")
                        .font(.headline)
                        .fontWeight(.bold)
        
                }
                .sheet(isPresented: $isShowingSettings) {
                    TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange)
                }
                .onAppear {
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

