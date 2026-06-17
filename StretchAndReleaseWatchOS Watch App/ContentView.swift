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
	@State private var endAngle = Angle(degrees: 340)
	
	// state variables only used on main view
	@State private var isShowingSettings = false
	@State private var offset: CGFloat = 0
	
	//SwiftData query
	@Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
	
	// playlist properties
	@State var playlistItem: PlaylistItem?
	@State private var playlistIndex: Int? = 0
	
	//Connectivity class for communication with phone
	@State private var connectivity = Connectivity()
	
	var body: some View {
		NavigationStack {
			ZStack {
				TabView {
					Tab {
						TimerActionViewWatch(timeRemaining: $timeRemaining, isShowingSettings: $isShowingSettings, playlistIndex: $playlistIndex, playlistItem: $playlistItem)
					}
					Tab {
						PlaylistViewWatch()
					}
				}
			}
		}
		
		//stops and resets tiner when settings view is toggled
		.onChange(of: isShowingSettings) {
			withAnimation(.smooth(duration: 1)) {
				managers.stopTimer()
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
			timeRemaining = totalStretch
			isPlaylistActive = connectivity.statusContext["playlist"] as? Bool ?? false
			connectivity.didStatusChange = false
		}
		
		//sends updated settings to iOS app
		.onChange(of: managers.didSettingsChange) {
			sendContext(stretch: totalStretch, rest: totalRest, reps: totalReps, playlist: isPlaylistActive)
			managers.didSettingsChange = false
		}
		
		//when user changes totalStretch in SettingsView, force timeRemaining to reset to TotalStretch
		.onChange(of: totalStretch, initial: true) {
			timeRemaining = totalStretch
		}
		
		.onAppear() {
			//prep audio tick sound
			SoundManager.instance.prepareTick(sound: .tick)
			SoundManager.instance.volume = promptVolume
			
			//load first playlist item, if playlist is active
			if isPlaylistActive {
				if !playlist.isEmpty {
					guard var playlistIndex else { return }
					playlistIndex = 0
					playlistItem = playlist[playlistIndex]
					if let playlistItem {
						totalStretch = playlistItem.stretchDuration ?? 10
						totalRest = playlistItem.restDuration ?? 5
						totalReps = playlistItem.repsToComplete ?? 3
					}
					timeRemaining = totalStretch
				} else {
					playlistItem = nil
					isPlaylistActive = false
				}
			} else {
				timeRemaining = totalStretch
				repsCompleted = 0
				managers.stretchPhase = .stop
			}
			
			//sets timeRemaining to totalStretch
			timeRemaining = totalStretch
		}
		._statusBarHidden()
	}
	
	//sends updated settings to iPhone
	func sendContext(stretch: Int, rest: Int, reps: Int, playlist: Bool) {
		let settingsUpdate: [String: Any] = ["stretch" : stretch, "rest" : rest, "reps" : reps, "playlist" : playlist]
		connectivity.setContext(to: settingsUpdate)
	}
}

#Preview {
	ContentView()
		.environment(Managers())
		.modelContainer(previewContainer)
}

