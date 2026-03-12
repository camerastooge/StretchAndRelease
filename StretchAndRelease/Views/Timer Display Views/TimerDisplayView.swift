//
//  TimerDisplayView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 3/10/26.
//

import SwiftUI
import SwiftData

struct TimerDisplayView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(Managers.self) var managers
    
    // Properties stored in UserDefaults
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    @AppStorage("promptVolume") private var promptVolume = 1.0
    @AppStorage("playlist") private var isPlaylistActive = false

    // state variables used across views
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var endAngle = Angle(degrees: 340)
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // SwiftData model and item for current playlist item
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    var playlistItem: PlaylistItem?
    
    // computed properties
    var timerTextLabel: String {
        if isPlaylistActive {
            if let name = playlistItem?.name {
                return name
            }
        }
        return managers.stretchPhase.phaseText
    }
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .phone
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear.gradientBackground()
            
            VStack(spacing: 0) {
                ZStack {
                    MainArcView(endAngle: $endAngle, timeRemaining: $timeRemaining, totalReps: $totalReps, repsCompleted: $repsCompleted, timerTextLabel: timerTextLabel)
                        
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
                        
                        //START - PAUSE BUTTON
                        StartPauseButtonView(repsCompleted: $repsCompleted)
                        .accessibilityLabel(!managers.isTimerActive ? "Start Timer" : "Pause Timer")
                        
                        Spacer()
                        
                        //RESET BUTTON
                        
                        ResetButtonView(timeRemaining: $timeRemaining, repsCompleted: $repsCompleted)
                        .accessibilityLabel("Reset Timer")
                        
                        Spacer()
                    }
                    .padding([.horizontal, .vertical])
                }
            }
            
            //this modifier runs when the timer publishes
            .onReceive(timer) { _ in
                if managers.isTimerActive && !managers.isTimerPaused {
                    switch managers.stretchPhase {
                    case .stretch: return {
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                            withAnimation(.easeOut(duration: 1.0)) {
                                updateEndAngle()
                            }
                            if audio {
                                SoundManager.instance.playTick(sound: .tick)
                            }
                        } else {
                            repsCompleted += 1
                            if repsCompleted < totalReps {
                                withAnimation {
                                    managers.stretchPhase = .rest
                                }
                                if audio {
                                    SoundManager.instance.playPrompt(sound: .rest)
                                }
                            } else {
                                timeRemaining = totalStretch
                                withAnimation(.easeOut(duration: 0.5)) {
                                    managers.stretchPhase = .stop
                                    updateEndAngle()
                                }
                                if audio {
                                    SoundManager.instance.playPrompt(sound: .relax)
                                }
                            }
                        }
                    }()
                        
                    case .rest: return {
                        if timeRemaining < totalRest {
                            timeRemaining += 1
                            withAnimation(.easeOut(duration: 1.0)) {
                                updateEndAngle()
                            }
                        } else {
                            timeRemaining = totalStretch
                            withAnimation {
                                managers.stretchPhase = .stretch
                            }
                            if audio {
                                SoundManager.instance.playPrompt(sound: .stretch)
                            }
                        }
                    }()
                        
                    case .stop: return {
                        managers.stopTimer()
                        updateEndAngle()
                    }()
                    }
                } else if managers.stretchPhase == .stop {
                    withAnimation(.easeOut(duration: 0.25)) {
                        updateEndAngle()
                    }
                }
            }
            
            //when user changes totalStretch in SettingsView, or app launches and loads totalStretch from AppStorage, force timeRemaining to reset to TotalStretch
            .onChange(of: totalStretch, initial: true) {
                timeRemaining = totalStretch
            }
            
            //stops and resets timer when either settings or help views are toggled
            .onChange(of: managers.didStatusChange) {
                withAnimation(.smooth(duration: 0.25)) {
                    managers.stopTimer()
                    timeRemaining = totalStretch
                    repsCompleted = 0
                    endAngle = Angle(degrees: 340)
                }
            }

        }
    }
    
    //function to set end angle of arc
    func updateEndAngle() {
        switch managers.stretchPhase {
        case .stretch:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(totalStretch) * 320 + 20)
        case .rest:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(totalRest) * 320 + 20)
        case .stop:
            endAngle = Angle(degrees: 340)
        }
    }
}

#Preview {
    TimerDisplayView()
        .modelContainer(previewContainer)
        .environment(Managers())
}
