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
    
    var body: some View {
        NavigationStack {
            VStack {
                TimerActionViewWatch(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
                    .containerRelativeFrame(.vertical) { size, axis in
                        size * 0.9
                    }
//                    .padding(.top, 5)
//                    .padding(.bottom, 5)
                
                
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "playpause.fill")
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        isResetToggled.toggle()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 40, height: 40)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        isShowingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .frame(width: 40, height: 40)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            .ignoresSafeArea()
            .containerRelativeFrame(.vertical) { size, axis in
                size * 0.33
            }
            .sheet(isPresented: $isShowingSettings) {
                TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
        }
        }
    }
}

#Preview {
    TimerMainViewWatch()
}
