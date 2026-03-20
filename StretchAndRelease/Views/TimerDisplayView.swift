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
    
    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    // local properties
    @State var playlistItem: PlaylistItem?
    @State private var currentIndex = 0
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .phone
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear.gradientBackground()
            
            VStack(spacing: 0) {
                ZStack {
                    MainArcView(endAngle: $endAngle, timeRemaining: $timeRemaining, totalReps: $totalReps, repsCompleted: $repsCompleted, timerTextLabel: playlistItem?.name ?? managers.stretchPhase.phaseText)
                        
                }
                .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                    length * 0.9
                }
                .frame(minHeight: 0, maxHeight: .infinity)
                .layoutPriority(1)
                
                // playlist button row
                if isPlaylistActive {
                    ZStack {
                        Color.gray.opacity(differentiateWithoutColor ? 0 : 0.25)
                        HStack {
                            Spacer()
                            
                            //PREVIOUS EXERCISE BUTTON
                            Button {
                                currentIndex -= 1
                                if currentIndex < 0 {
                                    currentIndex = playlist.count - 1
                                }
                                loadPlaylistItem(currentIndex)
                            } label: {
                                ButtonView(buttonRoles: .previousItem, deviceType: deviceType)
                                    .opacity(0.75)
                            }
                            .accessibilityLabel("Go to previous item in set list")
                            
                            Spacer()
                            
                            //NEXT EXERCISE BUTTON
                            Button {
                                currentIndex += 1
                                if currentIndex == playlist.count {
                                    currentIndex = 0
                                }
                                loadPlaylistItem(currentIndex)
                            } label: {
                                ButtonView(buttonRoles: .nextItem, deviceType: deviceType)
                                    .opacity(0.75)
                            }
                            .accessibilityLabel("Go to next item in set list")

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                    .padding(.bottom, 5)
                }
                
                //Normal Button Row
                ZStack {
                    Color.black.opacity(differentiateWithoutColor ? 0.0 : 0.25)
                    HStack {
                        Spacer()
                        
                        //START - PAUSE BUTTON
                        Button {
                            //engage from full stop
                            if managers.stretchPhase == .stop {
                                if audio {
                                    SoundManager.instance.playPrompt(sound: .countdownExpanded)
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3 : .now() + 0.5) {
                                    withAnimation(.linear(duration: 0.25)) {
                                        managers.startTimer()
                                        repsCompleted = 0
                                    }
                                }
                            }
                            
                            //pause the timer
                            else if !managers.isTimerPaused {
                                managers.isTimerActive = false
                                managers.isTimerPaused = true
                            }
                            
                            //un-pause the timer
                            else {
                                if audio {
                                    SoundManager.instance.playPrompt(sound: .countdown)
                                }
                                DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3 : .now() + 0.5) {
                                    withAnimation(.linear(duration: 0.25)) {
                                        managers.isTimerActive = true
                                        managers.isTimerPaused = false
                                    }
                                }
                                
                            }
                        } label: {
                            ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
                        }
                        .accessibilityLabel(!managers.isTimerActive ? "Start Timer" : "Pause Timer")
                        
                        Spacer()
                        
                        //RESET BUTTON
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                managers.stretchPhase = .stop
                                managers.isTimerActive = false
                                managers.isTimerPaused = false
                            }
                            repsCompleted = 0
                            timeRemaining = totalStretch
                        } label: {
                            ButtonView(buttonRoles: .reset, deviceType: .phone)
                        }
                        .accessibilityLabel("Reset Timer")
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
                .padding(.bottom, 5)
                
            }
            
            //this modifier runs when the timer publishes
            .onReceive(timer) { _ in
                    if managers.isTimerActive && !managers.isTimerPaused {
                        switch managers.stretchPhase {
                        case .stretch: return manageStretch()
                        case .rest: return manageRest()
                        case .stop: return manageStop()
                        }
                    } else if managers.stretchPhase == .stop {
                        managers.stretchPhase = .stop
                        managers.isTimerActive = false
                        managers.isTimerPaused = false
                        timeRemaining = totalStretch
                        withAnimation(.easeOut(duration: 0.5)) {
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
                    managers.stretchPhase = .stop
                    managers.isTimerActive = false
                    managers.isTimerPaused = false
                    timeRemaining = totalStretch
                    repsCompleted = 0
                    endAngle = Angle(degrees: 340)
                }
            }
            
            .onChange(of: isPlaylistActive) {
                if isPlaylistActive {
                    currentIndex = 0
                    loadPlaylistItem(currentIndex)
                } else {
                    playlistItem = nil
                }
            }
            
            .onAppear {
                if isPlaylistActive && !playlist.isEmpty {
                    loadPlaylistItem(currentIndex)
                } else {
                    playlistItem = nil
                }
            }
            
            .onDisappear {
                withAnimation(.linear(duration: 0.25)) {
                    managers.stretchPhase = .stop
                    updateEndAngle()
                }
                managers.isTimerActive = false
                managers.isTimerPaused = false
                timeRemaining = totalStretch
            }
        }
    }
    
    //load playlistItem values into timer properties
    func loadPlaylistItem(_ index: Int) {
        playlistItem = playlist[index]
        if let playlistItem {
            totalStretch = playlistItem.stretchDuration ?? 10
            totalRest = playlistItem.restDuration ?? 5
            totalReps = playlistItem.repsToComplete ?? 3
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

    //function to stop timer
    func timerFullStop() {
        if audio {
            SoundManager.instance.playPrompt(sound: .relax)
        }
        withAnimation(.easeOut(duration: 0.5)) {
            managers.stretchPhase = .stop
            updateEndAngle()
        }
        timeRemaining = totalStretch
    }
    
    //function to manage stretch portion of stretch
    func manageStretch() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            withAnimation(.easeOut(duration: 1)) {
                updateEndAngle()
            }
            if audio {
                SoundManager.instance.playTick(sound: .tick)
            }
        } else {
            repsCompleted += 1
            if repsCompleted < totalReps {
                if audio {
                    SoundManager.instance.playPrompt(sound: .rest)
                }
                withAnimation {
                    managers.stretchPhase = .rest
                }
            } else {
                if !isPlaylistActive {
                    timerFullStop()
                } else {
                    if currentIndex != playlist.count - 1 {
                        if audio {
                            SoundManager.instance.playPrompt(sound: .rest)
                        }
                        withAnimation {
                            managers.stretchPhase = .rest
                        }
                    } else {
                        timerFullStop()
                        currentIndex = 0
                        loadPlaylistItem(currentIndex)
                    }
                }
            }
        }
    }
    
    //function to manage rest portion of stretch
    func manageRest() {
        if timeRemaining != totalRest {
            timeRemaining += 1
            withAnimation(.easeOut(duration: 1)) {
                updateEndAngle()
            }
        } else {
            //not using playlist feature -> throws back to stretch phase
            if !isPlaylistActive {
                timeRemaining = totalStretch
                withAnimation {
                    managers.stretchPhase = .stretch
                }
                if audio {
                    SoundManager.instance.playPrompt(sound: .stretch)
                }
            } else {
                //using playlist feature -> reps completed, go to next exercise
                if repsCompleted == totalReps {
                    managers.isTimerActive = false
                    withAnimation(.linear(duration: 0.5)) {
                        managers.stretchPhase = .stretch
                        repsCompleted = 0
                    }
                    currentIndex += 1
                    loadPlaylistItem(currentIndex)
                    timeRemaining = totalStretch
                    if audio {
                        SoundManager.instance.playPrompt(sound: .countdownExpanded)
                    }
                    DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3 : .now() + 0.25) {
                        managers.isTimerActive = true
                    }
                } else {
                   // using playlist feature -> reps not completed, go to stretch phase
                    timeRemaining = totalStretch
                    withAnimation {
                        managers.stretchPhase = .stretch
                    }
                    if audio {
                        SoundManager.instance.playPrompt(sound: .stretch)
                    }
                }
            }
        }
    }
    
    //function to manage timer stop
    func manageStop() {
        withAnimation(.easeOut(duration: 1)) {
            managers.stretchPhase = .stop
            managers.isTimerActive = false
            managers.isTimerPaused = false
            updateEndAngle()
        }
    }
}

#Preview {
    TimerDisplayView()
        .environment(Managers())
        .modelContainer(previewContainer)
}
