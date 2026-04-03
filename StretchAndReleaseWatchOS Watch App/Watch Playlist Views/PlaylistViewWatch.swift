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
	@State private var isComingFromParentView = true
	
	//Checks for determining playlist status
	@State private var isPlaylistInactive = false
	@State private var playlistHasBeenEmptied = false	
	@State private var isShowingActive = false
	
	//Bindings
	@Binding var selectedTab: Int
	
	//SwiftData models
	@Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
	
	var body: some View {
		NavigationStack {
			ZStack {
				if !playlist.isEmpty {
					VStack {
						List {
							Section {
								ForEach(playlist) { exercise in
									NavigationLink {
										EditExerciseViewWatch(playlistItem: exercise, isComingFromParentView: $isComingFromParentView)
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
								.onMove(perform: move)
							}
						}
						
						NavigationLink {
							   AddExerciseViewWatch()
						   } label: {
							   if #available(watchOS 26, *) {
								   Image(systemName: "plus.circle.fill")
									   .glassEffect()
									   .font(.title)
									   .foregroundColor(.green)
							   } else {
								   Image(systemName: "plus.circle.fill")
									   .tint(.blue)
							   }
						   }
						   .buttonStyle(.plain)
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
								.foregroundStyle(.blue)
						}
						.buttonStyle(.plain)
						
						Text("Set list is Empty")
							.font(.system(size: 32))
					} description: {
						Text("Press ADD to add a stretch to your set list")
							.font(.system(size: 16))
							.foregroundStyle(colorScheme == .dark ? .white : .black)
					}
					.containerRelativeFrame([.vertical, .horizontal])
					.scrollDisabled(true)
				}
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						withAnimation {
							selectedTab = 0
						}
					} label: {
						if #available(watchOS 26, *) {
							Image(systemName: "house.circle.fill")
								.glassEffect(.clear)
						} else {
							Image(systemName: "house.circle.fill")
						}
					}
					.buttonStyle(.plain)
				}
			}
		}
	}
}

extension PlaylistViewWatch {
	private func move(from source: IndexSet, to destination: Int) {
		//creates mutable version of the playlist array
		var mutableList = playlist
		
		//moves the item from source to destination in the list
		mutableList.move(fromOffsets: source, toOffset: destination)
		
		//updates the index poperty of the item to persist position in array
		for(index, item) in mutableList.enumerated() {
			item.index = index
		}
	}
}

#Preview {
	@Previewable @State var selectedTab = 2
	
	PlaylistViewWatch(selectedTab: $selectedTab)
		.modelContainer(previewContainer)
		.environment(Managers())
}
