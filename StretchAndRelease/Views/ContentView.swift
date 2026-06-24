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
    
    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
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
    @State private var playlistIndex: Int? = nil
	@State private var playlistItem: PlaylistItem? = nil
    
    // Connectivity class for communication with Apple Watch
    @State private var connectivity = Connectivity()
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .phone
    
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
					TimerDisplayView(playlistIndex: $playlistIndex, playlistItem: $playlistItem)
                }
                
                Tab("Set list", systemImage: "list.bullet") {
                    PlaylistView()
                        .navigationBarBackButtonHidden()
                }
            }
            .navigationTitle(navigationBarTitleString)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowingHelpView.toggle()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.blue)
                                .glassEffect()

                        } else {
                            Image(systemName: "questionmark.circle")

                        }
					}
					.accessibilityLabel("Show help screen")
					.accessibilityInputLabels(["help"])
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
					.accessibilityInputLabels(["settings"])
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
            SoundManager.instance.volume = promptVolume
            
            //sends context to Apple Watch if connected
            sendContext(stretch: totalStretch, rest: totalRest, reps: totalRest, playlistIndex: playlistIndex ?? 0, playlist: isPlaylistActive)
			
			//set playlistIndex to 0 if isPlaylistActive
			if isPlaylistActive {
				playlistIndex = 0
			}
        }
        
        .onChange(of: connectivity.didStatusChange) {
        //receives changed settings from Apple Watch app
            totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
            totalRest = connectivity.statusContext["rest"] as? Int ?? 5
            totalReps = connectivity.statusContext["reps"] as? Int ?? 5
            playlistIndex = connectivity.statusContext["playlistIndex"] as? Int ?? 0
			isPlaylistActive = connectivity.statusContext["playlist"] as? Bool ?? false
            connectivity.didStatusChange = false
        }
        
        //when settings change, updates main display and sends updated settings to Apple Watch app
        .onChange(of: managers.didSettingsChange) {
            sendContext(stretch: totalStretch, rest: totalRest, reps: totalReps, playlistIndex: playlistIndex ?? 0, playlist: isPlaylistActive)
			managers.didSettingsChange = false
        }
		
		//set playlistIndex when isPlaylistActive changes
		.onChange(of: isPlaylistActive) {
			if isPlaylistActive {
				playlistIndex = 0
			}
		}
    }
    
    //function sends updated settings to Apple Watch
    func sendContext(stretch: Int, rest: Int, reps: Int, playlistIndex: Int, playlist: Bool) {
        let settingsUpdate: [String : Any] = ["stretch" : stretch, "rest" : rest, "reps" : reps, "playlistIndex" : playlistIndex, "playlist" : playlist]
        connectivity.setContext(to: settingsUpdate)
		print("context sent")
    }
}
        


#Preview {
    ContentView()
        .modelContainer(previewContainer)
        .environment(Managers())
}
