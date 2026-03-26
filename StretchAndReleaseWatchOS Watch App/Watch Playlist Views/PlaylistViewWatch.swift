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
	@Environment(\.modelContext) var modelContext
	@Environment(Managers.self) var managers
	
	// Properties stored in UserDefaults
	@AppStorage("stretch") private var totalStretch = 10
	@AppStorage("rest") private var totalRest = 5
	@AppStorage("reps") private var totalReps = 3
	@AppStorage("playlist") private var isPlaylistActive = false
	
	//State properties
	@State private var name: String = ""
	@State private var stretchDuration: Int = 0
	@State private var restDuration: Int = 0
	@State private var repsNumber: Int = 0
	
	
	//Checks for determining playlist status
	@State private var isPlaylistInactive = false
	@State private var playlistHasBeenEmptied = false
	
	//Define columns for LazyVGrid
	private let playlistColumns: [GridItem] = [
		GridItem(.flexible(minimum: 150), alignment: .leading),
		GridItem(.fixed(60), alignment: .center),
		GridItem(.fixed(60), alignment: .center),
		GridItem(.fixed(70), alignment: .center),
	]
	
	@State private var isShowingActive = false
	
	//Bindings
	@Binding var selectedTab: Int
	
	//SwiftData models
	@Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
	
	var body: some View {
		NavigationStack {
			ZStack {
				if !playlist.isEmpty {
					List {
						Section(header: playlistHeaderView()) {
							ForEach(playlist) { exercise in
								NavigationLink {
									EditExerciseRowViewWatch(playlistItem: exercise)
								} label: {
									Text(exercise.name ?? "Exercise")
										.fontWeight(.bold)
										.swipeActions(edge: .trailing, allowsFullSwipe: true) {
											Button {
												modelContext.delete(exercise)
											} label: {
												Label("Delete", systemImage: "trash")
													.tint(.red)
													.accessibilityLabel("Delete \(exercise.name ?? "exercise")")
													.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
											}
										}
								}
								.navigationLinkIndicatorVisibility(.hidden)
								.accessibilityLabel("Edit \(exercise.name ?? "exercise")")
								.listRowBackground(Color.clear)
							}
						}
					}
				}
				else {
					ContentUnavailableView {
						NavigationLink {
							AddExerciseViewWatch()
						} label: {
							Image(systemName: "plus.circle")
								.font(.title)
								.fontWeight(.bold)
						}
						.buttonStyle(.plain)
						
						Text("Playlist is Empty")
							.font(.title)
					} description: {
						Text("Press ADD to add a stretch to your set list")
							.font(.system(size: 16))
							.foregroundStyle(colorScheme == .dark ? .white : .black)
					}
					.containerRelativeFrame([.vertical, .horizontal])
					.scrollDisabled(true)
				}
			}
		}
	}
}

struct playlistHeaderView: View {
	//Environment properties
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
	@Environment(\.dynamicTypeSize) var sizeCategory
	
	var body: some View {
		Text("Name")
			.font(.headline)
			.fontWeight(.bold)
			.foregroundStyle(colorScheme == .dark ? .secondary : Color.white.opacity(0.7))
			.lineLimit(1)
			.padding(.leading, 5)
			.accessibilityLabel("Name")
			.accessibilityHint("The name of the selected sretch")
	}
}

#Preview {
	@Previewable @State var selectedTab = 2
	
	PlaylistViewWatch(selectedTab: $selectedTab)
//		.modelContainer(previewContainer)
		.environment(Managers())
}
