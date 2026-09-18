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
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(StretchTimer.self) private var timer

    //State properties
    @State private var isShowingHelpView: Bool = false

    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()

    //variable for navigation title
    var navigationBarTitleString: String {
        switch sizeCategory {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: "S & R"
        default: "Stretch & Release"
        }
    }

    var body: some View {
        NavigationStack {
            TabView() {
                Tab("Timer", systemImage: "timer") {
                    TimerDisplayView()
                }

                Tab("Set list", systemImage: "list.bullet") {
                    PlaylistView()
                        .navigationBarBackButtonHidden()
                }
            }
            .navigationTitle(navigationBarTitleString)
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowingHelpView.toggle()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.blue)
                                .glassEffect()
                                .accessibilityLabel("Show help")
                        } else {
                            Image(systemName: "questionmark.circle")
                                .accessibilityLabel("Show help")
                        }
                    }
                }

                if #available(iOS 26.0, *) {
                    ToolbarSpacer()
                }

                ToolbarItem {
                    NavigationLink {
                        SettingsView()
                            .navigationBarBackButtonHidden()
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
        .sheet(isPresented: $isShowingHelpView) {
            MainHelpScreenView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }

        .onAppear() {
            //prep tick audio player when app launches
            SoundManager.instance.prepareTick(sound: .tick)
            SoundManager.instance.volume = timer.settings.promptVolume

            //sends context to Apple Watch if connected
            sendContext()
        }

        .onChange(of: connectivity.didStatusChange) {
            guard connectivity.didStatusChange else { return }
            //receives changed settings from Apple Watch app
            let settings = timer.settings
            settings.stretchDuration = connectivity.statusContext["stretch"] as? Int ?? 10
            settings.restDuration = connectivity.statusContext["rest"] as? Int ?? 5
            settings.repsToComplete = connectivity.statusContext["reps"] as? Int ?? 5
            settings.isPlaylistActive = connectivity.statusContext["playlist"] as? Bool ?? false
            timer.settingsDidChange()
            connectivity.didStatusChange = false
        }

        //when settings change, updates main display and sends updated settings to Apple Watch app
        .onChange(of: timer.settings.didChange) {
            guard timer.settings.didChange else { return }
            timer.settingsDidChange()
            sendContext()
            timer.settings.didChange = false
        }
    }

    //function sends updated settings to Apple Watch
    func sendContext() {
        let settings = timer.settings
        let settingsUpdate: [String : Any] = [
            "stretch": settings.stretchDuration,
            "rest": settings.restDuration,
            "reps": settings.repsToComplete,
            "playlistIndex": timer.playlistIndex ?? 0,
            "playlist": settings.isPlaylistActive
        ]
        connectivity.setContext(to: settingsUpdate)
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
        .environment(StretchTimer())
}
