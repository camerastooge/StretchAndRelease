//
//  ContentView.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
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
    @State private var isTimerActive = false
    @State private var isTimerPaused = false
    @State private var stretchPhase: StretchPhase = .stop
    @State private var endAngle = Angle(degrees: 340)
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // state variables only used on main view
    @State private var isShowingSettings = false
    @State private var didSettingsChange = false
    
    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    // local properties
    @State var playlistItem: PlaylistItem?
    @State private var currentIndex = 0
	
	var timerTextLabel: String {
		playlistItem?.name ?? managers.stretchPhase.phaseText
	}
    
    //Connectivity class for communication with phone
    @State private var connectivity = Connectivity()
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .watch
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                //Screen area for TimerActionViewWatch
                VStack {
                    ZStack {
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
                                        Text(!isTimerPaused ? timerTextLabel : "PAUSED")
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
                                            if audio {
                                                SoundManager.instance.playPrompt(sound: .countdownExpanded)
                                            }
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
                                            if audio {
                                                SoundManager.instance.playPrompt(sound: .countdownExpanded)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                withAnimation(.linear(duration: 0.25)) {
                                                    isTimerPaused = false
                                                    isTimerActive = true
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    ButtonView(buttonRoles: !isTimerActive ? .play : .pause, deviceType: deviceType)
                                    
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
                                    ButtonView(buttonRoles: .reset, deviceType: deviceType)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing)
                                .accessibilityInputLabels(["Reset", "Reset Timer"])
                                .accessibilityLabel("Reset Timer")
                                
                                Button {
                                    isShowingSettings.toggle()
                                } label: {
                                    ButtonView(buttonRoles: .settings, deviceType: deviceType)
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
                    TimerSettingsViewWatch(didSettingsChange: $didSettingsChange)
                }
                
                //stops and resets tiner when settings view is toggled
                .onChange(of: isShowingSettings) {
                    withAnimation(.smooth(duration: 0.25)) {
                        stretchPhase = .stop
                        timeRemaining = totalStretch
                        repsCompleted = 0
                        endAngle = Angle(degrees: 340)
                    }
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
                
                //prep tick audio player when app launches
                .onAppear() {
                    SoundManager.instance.prepareTick(sound: .tick)
                    SoundManager.instance.volume = promptVolume
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
            }
        }
        ._statusBarHidden()
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
    
    //load playlistItem values into timer properties
    func loadPlaylistItem(_ index: Int) {
        playlistItem = playlist[index]
        if let playlistItem {
            totalStretch = playlistItem.stretchDuration ?? 10
            totalRest = playlistItem.restDuration ?? 5
            totalReps = playlistItem.repsToComplete ?? 3
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
		.modelContainer(previewContainer)
		.environment(Managers())
}

