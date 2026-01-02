//
//  ContentView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.sizeCategory) var sizeCategory
    
    // Settings stored in AppStorage
    @EnvironmentObject var settings: Settings
    
    // state variables used across views
    @State private var stretchPhase: StretchPhase = .stop
    
    // state variables only used on main view
    @State private var isShowingSettings = false
    @State private var didSettingsChange = false
    @State private var isShowingHelp = false
    @State private var isResetToggled = false
    
    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()
    
    // variables for button view
    @State private var buttonRoles: ButtonRoles = .play
    @State private var deviceType: DeviceType = .phone

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                Color.clear
                    .background(
                        LinearGradient(gradient: Gradient(colors: colorScheme == .dark ? [.black, .gray] : [.gray, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                VStack(spacing: 0) {
                    ZStack {
                        VStack {
                            //need to put countdown display here
                            TimerCompositeView(stretchPhase: $stretchPhase)
                        }
                        .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                            length * 0.85
                        }
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .layoutPriority(1)
                    }
                        
                        //Button Row
                        ButtonRowView(stretchPhase: $stretchPhase, deviceType: $deviceType)
                }
            }
                .navigationTitle("Stretch & Release")
                .toolbar {
                    ToolbarItem {
                        Button {
                            isShowingHelp.toggle()
                        } label: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundStyle(.blue)
                                    .glassEffect()
                            } else {
                                Image(systemName: "questionmark.circle.fill")
                            }
                        }
                    }
                    
                    if #available(iOS 26.0, *) {
                        ToolbarSpacer()
                    }
                    
                    ToolbarItem {
                        Button {
                            isShowingSettings.toggle()
                        } label: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "gear")
                                    .foregroundStyle(.blue)
                                    .glassEffect()
                            } else {
                                Image(systemName: "gear")
                            }
                        }
                        .accessibilityInputLabels(["Settings"])
                        .accessibilityLabel("Show Settings")
                    }
                }
                
            }
            //sheet presents settings menu
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(didSettingsChange: $didSettingsChange)
            }
            
            //sheet presents help screen
            .sheet(isPresented: $isShowingHelp) {
                MainHelpScreenView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            
            //stops and resets timer when either settings or help views are toggled
            .onChange(of: isShowingSettings || isShowingHelp) {
                stretchPhase = .stop
            }
            
            //receives changed settings from Apple Watch app
            .onChange(of: connectivity.didStatusChange) {
                settings.totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
                settings.totalRest = connectivity.statusContext["rest"] as? Int ?? 5
                settings.totalReps = connectivity.statusContext["reps"] as? Int ?? 5
                connectivity.didStatusChange = false
            }
            
            //when settings change, updates main display and sends updated settings to Apple Watch app
            .onChange(of: didSettingsChange) {
                stretchPhase = .stop
                sendContext(stretch: settings.totalStretch, rest: settings.totalRest, reps: settings.totalReps)
                didSettingsChange = false
            }
            
            //prep tick audio player when app launches
            .onAppear() {
                SoundManager.instance.prepareTick(sound: .tick)
                SoundManager.instance.volume = settings.promptVolume
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
        .environmentObject(Settings.previewData)
        .environment(Switches())
}
