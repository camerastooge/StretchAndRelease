//
//  ContentView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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
    
    //State properties
    @State private var isShowingHelpView: Bool = false
    @State private var isShowingSettings: Bool = false
    
    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .phone
    
    //variable for navigation title
    var navigationBarTitleString: String {
        switch sizeCategory {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge: "Stretch & Release"
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: "S & R"
        default: "S & R"
        }
    }

    var body: some View {
        NavigationStack {
            TabView {
                Tab("Timer", systemImage: "timer") {
                    TimerDisplayView()
                }
                
                Tab("Set list", systemImage: "list.bullet") {
                    PlaylistView()
                }
            }
            .navigationTitle(navigationBarTitleString)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowingHelpView.toggle()
                        managers.didStatusChange.toggle()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.blue)
                                .glassEffect()
                                .accessibilityLabel("Show playlist")

                        } else {
                            Image(systemName: "questionmark.circle")
                                .accessibilityLabel("Show playlist")

                        }                    }
                }
                
                if #available(iOS 26.0, *) {
                    ToolbarSpacer()
                }
                
                ToolbarItem {
                    Button {
                        isShowingSettings.toggle()
                        managers.didStatusChange.toggle()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "gear")
                                .foregroundStyle(.blue)
                                .glassEffect()
                        } else {
                            Image(systemName: "gear")
                        }
                    }
                    .accessibilityLabel("Show Settings")
                }
            }

        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        
        .sheet(isPresented: $isShowingHelpView) {
            MainHelpScreenView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        
        //prep tick audio player when app launches
        .onAppear() {
            SoundManager.instance.prepareTick(sound: .tick)
            SoundManager.instance.volume = promptVolume
        }
        
        .onChange(of: connectivity.didStatusChange) {
        //receives changed settings from Apple Watch app
            totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
            totalRest = connectivity.statusContext["rest"] as? Int ?? 5
            totalReps = connectivity.statusContext["reps"] as? Int ?? 5
            connectivity.didStatusChange = false
        }
        
        //when settings change, updates main display and sends updated settings to Apple Watch app
        .onChange(of: managers.didStatusChange) {
            managers.stretchPhase = .stop
            managers.isTimerActive = false
            managers.isTimerPaused = false
            sendContext(stretch: totalStretch, rest: totalRest, reps: totalReps)
            managers.didStatusChange = false
        }
    }
    
    //function sends updated settings to Apple Watch
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
