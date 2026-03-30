//
//  EditExerciseRowViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 3/26/26.
//

import SwiftUI

struct EditExerciseViewWatch: View {
	//Environment properties
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
	@Environment(\.dynamicTypeSize) var sizeCategory
	@Environment(\.dismiss) var dismiss
	@Environment(\.modelContext) var modelContext
	
	@State var name = ""
	@State var stretch = 10
	@State var rest = 5
	@State var reps = 3
	
	@State var isExerciseUnsaved = false
	
	@Bindable var playlistItem: PlaylistItem
	
	@ScaledMetric var buttonWidth = 65
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					TextField(name, text: $name)
						.accessibilityHint("Change the name of the stretch")
					NavigationLink {
						Picker("Stretch", selection: $stretch) {
							ForEach(1...60, id:\.self) {
								Text("\($0)")
									.font(.headline)
									.fontWeight(.bold)
									.accessibilityHint("Adjust the duration of the stretch period")
									.accessibilityValue(String(stretch))
									.accessibilityAdjustableAction { direction in
										switch direction {
										case .increment: stretch += 1
										case .decrement: stretch -= 1
										@unknown default: print("not handled")
										}
									}
							}
						}
					} label: {
						Text("Stretch: \(stretch)")
							.accessibilityLabel("Stretch duration: \(stretch) seconds")
							.accessibilityHint("Adjust the duration of the stretch period")
					}
					NavigationLink {
						Picker("Rest", selection: $rest) {
							ForEach(1...30, id: \.self) {
								Text("\($0)")
									.font(.headline)
									.fontWeight(.bold)
									.accessibilityHint("Adjust the duration of the rest period")
									.accessibilityValue(String(rest))
									.accessibilityAdjustableAction { direction in
										switch direction {
										case .increment: stretch += 1
										case .decrement: stretch -= 1
										@unknown default: print("not handled")
										}
									}
							}
						}
					} label: {
						Text("Rest: \(rest)")
							.accessibilityLabel("Rest duration: \(rest) seconds")
							.accessibilityHint("Adjust the duration of the rest period")
					}
					NavigationLink {
						Picker("Repetitions", selection: $reps) {
							ForEach(1...20, id: \.self) {
								Text("\($0)")
									.font(.headline)
									.fontWeight(.bold)
									.accessibilityHint("Adjust the number of repetitions in this set")
									.accessibilityValue(String(reps))
									.accessibilityAdjustableAction { direction in
										switch direction {
										case .increment: reps += 1
										case .decrement: reps -= 1
										@unknown default: print("not handled")
										}
									}
							}
						}
					} label: {
						Text("Reps: \(reps)")
							.accessibilityLabel("Number of repetitions: \(reps)")
							.accessibilityHint("Adjust the number of repetitions")
					}
				}
				HStack {
					Spacer()
					
					Button {
						playlistItem.name = name
						playlistItem.stretchDuration = stretch
						playlistItem.restDuration = rest
						playlistItem.repsToComplete = reps
						modelContext.insert(playlistItem)
						do {
							try modelContext.save()
						} catch {
							print("Error: \(error.localizedDescription)")
						}
						dismiss()
					} label: {
						if #available(watchOS 26.0, *) {
							Text("SAVE")
								.frame(width: buttonWidth, height: 30)
								.font(.headline)
								.fontWeight(.bold)
								.foregroundStyle(.white)
								.background(.green)
								.clipShape(.capsule)
								.glassEffect()
								.dynamicTypeSize(...DynamicTypeSize.accessibility2)
						} else {
							Text("SAVE")
								.frame(width: buttonWidth, height: 30)
								.font(.headline)
								.fontWeight(.bold)
								.foregroundStyle(.white)
								.background(.green)
								.clipShape(.capsule)
								.dynamicTypeSize(...DynamicTypeSize.accessibility2)
						}
					}
					
					Spacer()
				}
			}
			.navigationTitle("Edit Stretch")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						isExerciseUnsaved = true
					} label: {
						if #available(watchOS 26, *) {
							Image(systemName: "x.circle")
								.background(.red)
								.foregroundColor(.white)
								.clipShape(.circle)
								.glassEffect(.clear)
						} else {
							Image(systemName: "x.circle")
								.background(.red)
								.foregroundColor(.white)
								.clipShape(.circle)
						}
					}
				}
				
			}
		}
		.onAppear {
			name = playlistItem.name ?? "Exercise"
			stretch = playlistItem.stretchDuration ?? 10
			rest = playlistItem.restDuration ?? 5
			reps = playlistItem.repsToComplete ?? 3
		}
		
		.alert("Save Stretch?",isPresented: $isExerciseUnsaved) {
			Button("OK") {
				dismiss()
			}
			
			Button("Cancel", role: .cancel) {
				isExerciseUnsaved = false
			}
			
		} message: {
			Text("If you cancel, your changes will not be saved.")
		}
	}
}

#Preview {
	@Previewable @State var item = PlaylistItem.sampleData[0]
	
	EditExerciseViewWatch(playlistItem: item)
}
