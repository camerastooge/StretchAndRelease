//
//  AddExerciseViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 3/26/26.
//

import SwiftUI
import SwiftData

struct AddExerciseViewWatch: View {
	//Environment properties
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
	@Environment(\.dynamicTypeSize) var sizeCategory
	@Environment(\.dismiss) var dismiss
	@Environment(\.modelContext) var modelContext
	
	//SwiftData property
	@Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
	
	@State private var name = ""
	@State private var stretch = 10
	@State private var rest = 5
	@State private var reps = 3
	@State private var isShowingEmptyNameField = false
	
    var body: some View {
		NavigationStack {
			List {
				Section {
					TextField("Name your stretch", text: $name)
						.accessibilityHint("Enter a name for this stretch")
					NavigationLink {
						Picker("Stretch", selection: $stretch) {
							ForEach(1...60, id:\.self) {
								Text("\($0)")
									.font(.headline)
									.fontWeight(.bold)
									.accessibilityHint("Set the duration for the stretch")
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
							.accessibilityHint("Set the duration for the stretch")
					}
					NavigationLink {
						Picker("Rest", selection: $rest) {
							ForEach(1...30, id: \.self) {
								Text("\($0)")
									.font(.headline)
									.fontWeight(.bold)
									.accessibilityHint("Set the duration of the rest period")
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
							.accessibilityHint("Set the duration of the rest period")
					}
					NavigationLink {
						Picker("Repetitions", selection: $reps) {
							ForEach(1...20, id: \.self) {
								Text("\($0)")
									.font(.headline)
									.fontWeight(.bold)
									.accessibilityHint("Set the number of repetitions in this set")
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
							.accessibilityHint("Set the number of repetitions")
					}
				}
				HStack {
					Spacer()
					
					Button {
						if !name.isEmpty {
							let item = PlaylistItem(index: playlist.isEmpty ? 0 : playlist.count + 1, name: name, stretchDuration: stretch, restDuration: rest, repsToComplete: reps)
							modelContext.insert(item)
							do {
							 try modelContext.save()
						 } catch {
							 print("Error: \(error.localizedDescription)")
						 }
						 dismiss()
						} else {
							isShowingEmptyNameField = true
						}
					} label: {
						if #available(watchOS 26.0, *) {
							Text("SAVE")
								.frame(width: 75, height: 30)
								.font(.headline)
								.fontWeight(.bold)
								.foregroundStyle(.white)
								.background(.green)
								.clipShape(.capsule)
								.glassEffect()
								.dynamicTypeSize(...DynamicTypeSize.accessibility2)
						} else {
							Text("SAVE")
								.frame(width: 75, height: 30)
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
			.navigationTitle(name)
			.navigationBarTitleDisplayMode(.inline)
			.alert("Name Field Is Empty", isPresented: $isShowingEmptyNameField) {
				Button("OK", role: .cancel) {
					isShowingEmptyNameField = false
				}
			} message: {
				Text("You must name your exercise.")
			}
		}
	}
}

#Preview {
    AddExerciseViewWatch()
}
