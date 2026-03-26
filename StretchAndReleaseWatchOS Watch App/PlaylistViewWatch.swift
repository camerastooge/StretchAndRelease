//
//  PlaylistViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 3/25/26.
//

import SwiftUI
import SwiftData

struct PlaylistViewWatch: View {
	//Environment properties
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
	@Environment(\.scenePhase) var scenePhase
	@Environment(Managers.self) var managers
	
	// Properties stored in UserDefaults
	@AppStorage("stretch") private var totalStretch = 10
	@AppStorage("rest") private var totalRest = 5
	@AppStorage("reps") private var totalReps = 3
	@AppStorage("playlist") private var isPlaylistActive = false
	
	//Bindings
	@Binding var selectedTab: Int
	
	//SwiftData models
	@Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
	
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
	@Previewable @State var selectedTab = 2
	
	PlaylistViewWatch(selectedTab: $selectedTab)
		.modelContainer(previewContainer)
		.environment(Managers())
}
