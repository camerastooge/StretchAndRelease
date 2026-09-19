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
	@Environment(StretchTimer.self) private var timer

	//SwiftData query
	@Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]

	//Connectivity class for communication with phone
	@State private var connectivity = Connectivity()

	//Keeps the app awake while the timer is counting
	@State private var runtimeSession = StretchSession()

	var body: some View {
		NavigationStack {
			TabView {
				Tab {
					TimerDisplayViewWatch()
				}
				Tab {
					PlaylistViewWatch()
				}
			}
		}

		//keep the timer's copy of the set list current
		.onChange(of: playlist, initial: true) {
			timer.syncPlaylist(playlist)
		}

		//receives changed settings from iOS app
		.onChange(of: connectivity.didStatusChange) {
			guard connectivity.didStatusChange else { return }
			let settings = timer.settings
			settings.stretchDuration = connectivity.statusContext["stretch"] as? Int ?? 10
			settings.restDuration = connectivity.statusContext["rest"] as? Int ?? 5
			settings.repsToComplete = connectivity.statusContext["reps"] as? Int ?? 5
			settings.isPlaylistActive = connectivity.statusContext["playlist"] as? Bool ?? false
			timer.settingsDidChange()
			connectivity.didStatusChange = false
		}

		//sends updated settings to iOS app
		.onChange(of: timer.settings.didChange) {
			guard timer.settings.didChange else { return }
			timer.settingsDidChange()
			sendContext()
			timer.settings.didChange = false
		}

		.onAppear() {
			//prep audio tick sound
			SoundManager.instance.prepareTick(sound: .tick)
			SoundManager.instance.volume = timer.settings.promptVolume

			//hold an extended runtime session for the length of a run, so the
			//watch doesn't suspend the app (and stall the ticker) on wrist-down
			timer.onRunningChanged = { [runtimeSession] isRunning in
				if isRunning {
					runtimeSession.start()
				} else {
					runtimeSession.stop()
				}
			}
		}
		._statusBarHidden()
	}

	//sends updated settings to iPhone
	func sendContext() {
		let settings = timer.settings
		let settingsUpdate: [String: Any] = [
			"stretch": settings.stretchDuration,
			"rest": settings.restDuration,
			"reps": settings.repsToComplete,
			"playlist": settings.isPlaylistActive
		]
		connectivity.setContext(to: settingsUpdate)
	}
}

#Preview {
	ContentView()
		.environment(StretchTimer())
		.modelContainer(previewContainer)
}
