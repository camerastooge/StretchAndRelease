//
//  ContentView.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI

struct TimerMainViewWatch: View {
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
    
    //local variable
    @State private var isResetToggled = false
    
    //Connectivity class for communication with phone
    @State private var connectivity = Connectivity()
    
    
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height
            let topHeight = totalHeight * 0.7
            let bottomHeight = totalHeight * 0.2
            
            VStack(spacing: 30) {
                TimerActionViewWatch(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
                    .frame(height: topHeight)
                    .padding(.horizontal)
                
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
                            .background(Color.green)
                            .clipShape(Circle())
                            .scaleEffect(0.85)
                    }
                    
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
                    
                    Button {
                        isShowingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .frame(width: 40, height: 40)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .scaleEffect(0.85)
                    }
                }
                .frame(height: bottomHeight)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            

        }
        .sheet(isPresented: $isShowingSettings) {
            TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
        }
        .onAppear {
            timeRemaining = totalStretch
        }
    }
}

#Preview {
    TimerMainViewWatch()
}

