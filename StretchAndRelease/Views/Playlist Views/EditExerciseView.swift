//
//  AddExerciseToPlaylistView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/26/26.
//

import SwiftUI
import SwiftData

struct EditExerciseView: View {
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
	@State private var isShowingEmptyNameField = false
    
    @Bindable var playlistItem: PlaylistItem
    
    @ScaledMetric var buttonWidth = 100
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color.clear.gradientBackground()
                    
					VStack {
						if !sizeCategory.isAccessibilitySize {
							PhoneAddExerciseViewTypical(name: $name, stretch: $stretch, rest: $rest, reps: $reps)
						} else {
							VStack {
								PhoneAddExerciseViewAccessible(name: $name, stretch: $stretch, rest: $rest, reps: $reps)
								Spacer()
							}
							.padding(.horizontal)
						}
					}
                }
                .navigationTitle("Edit Exercise")
                .navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						Button {
							if !name.isEmpty {
							 playlistItem.name = name
								playlistItem.stretchDuration = stretch
								playlistItem.restDuration = rest
								playlistItem.repsToComplete = reps
								try? modelContext.save()
								dismiss()
							} else {
								isShowingEmptyNameField = true
							}
						} label: {
							if #available(iOS 26.0, *) {
								Image(systemName: "chevron.left")
									.glassEffect(.clear)
									.font(.system(size: !differentiateWithoutColor ? 18 : 24))
							} else {
								Image(systemName: "chevron.left")
									.font(.system(size: !differentiateWithoutColor ? 18 : 24))
							}
						}
						.buttonStyle(.plain)
						.accessibilityLabel("Save changes and return to set list view")
						.accessibilityInputLabels(["save"])
					}
					
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(role: .cancel) {
							dismiss()
						} label: {
							if #available(iOS 26.0, *) {
								Image(systemName: "x.circle")
									.glassEffect(.clear)
									.font(.system(size: !differentiateWithoutColor ? 18 : 24))
									.foregroundStyle(!differentiateWithoutColor ? .red : .black)
							} else {
								Image(systemName: "x.circle.fill")
									.font(.system(size: !differentiateWithoutColor ? 18 : 24))
									.foregroundStyle(!differentiateWithoutColor ? .red : .black)
							}
						}
						.buttonStyle(.plain)
						.accessibilityLabel("Cancel and return to set list view")
						.accessibilityInputLabels(["cancel"])
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
		.alert("Name Field Is Empty", isPresented: $isShowingEmptyNameField) {
			Button("OK", role: .cancel) {
				isShowingEmptyNameField = false
			}
		} message: {
			Text("You must name your exercise.")
		}
    }
}

#Preview {
    @Previewable @State var item = PlaylistItem.sampleData[0]
    
    EditExerciseView(playlistItem: item)
}
