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
    @Environment(\.scenePhase) var scenePhase
    @Environment(Managers.self) var managers
    
    @StateObject var stretchSession = StretchSession()
    
    // Properties stored in UserDefaults
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    @AppStorage("promptVolume") private var promptVolume = 1.0
    @AppStorage("playlist") private var isPlaylistActive = true
    
    //SwiftData models
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    // state variables used across views
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var endAngle = Angle(degrees: 340)
    @State private var isShowingSettings = false
    @State private var didSettingsChange = false
    @State private var currentIndex = 0
    
    //Connectivity class for communication with phone
    @State private var connectivity = Connectivity()
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .watch
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .gradientBackground()
                
                //Screen area for TimerActionViewWatch
                GeometryReader { proxy in
                    TabView {
                        Tab {
                                VStack {
                                    TimerDisplayViewWatch(timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, didSettingsChange: $didSettingsChange)
                                        .padding(.horizontal)
                                        .padding(.bottom, 20)
                                        .containerRelativeFrame(.vertical, alignment: .leading) { length, _ in
                                            length * 0.8
                                        }
                                    
                                    TimerButtonRowViewWatch(stretchSession: stretchSession, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, didSettingsChange: $didSettingsChange, currentIndex: $currentIndex, endAngle: $endAngle)
                                        .containerRelativeFrame(.vertical, alignment: .trailing) { length, _ in
                                            length * 0.6
                                        }
                                }
                            }
                        Tab {
                            Text("Hello world")
                        }
                        
                    }
                }
                .sheet(isPresented: $isShowingSettings) {
                    TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, audio: $audio, haptics: $haptics, promptVolume: $promptVolume, didSettingsChange: $didSettingsChange)
                }
                
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingSettings.toggle()
                        } label: {
                            ButtonView(buttonRoles: .settings, deviceType: deviceType)
                                .tint(Color.blue)
                            
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                //stops and resets tiner when settings view is toggled
                .onChange(of: isShowingSettings) {
                    withAnimation(.smooth(duration: 0.25)) {
                        managers.stretchPhase = .stop
                        stretchSession.stop()
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
                
                //stop timer if application is fully backgrounded
                .onChange(of: scenePhase) {
                    if scenePhase == .background {
                        managers.stretchPhase = .stop
                        stretchSession.stop()
                    }
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
            }
        }
        ._statusBarHidden()
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

