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
    
    @Bindable var playlistItem: PlaylistItem
    
    @ScaledMetric var buttonWidth = 100
    
    var body: some View {
        ZStack {
            NavigationStack {
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
                .background {
                    Color.clear.gradientBackground()
                        .ignoresSafeArea()
                }
                .navigationTitle("Edit Exercise")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            name = playlistItem.name ?? "Exercise"
            stretch = playlistItem.stretchDuration ?? 10
            rest = playlistItem.restDuration ?? 5
            reps = playlistItem.repsToComplete ?? 3
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if !name.isEmpty {
                        playlistItem.name = name
                        playlistItem.stretchDuration = stretch
                        playlistItem.restDuration = rest
                        playlistItem.repsToComplete = reps
                        try? modelContext.save()
                        dismiss()
                    } else {
                        playlistItem.stretchDuration = stretch
                        playlistItem.restDuration = rest
                        playlistItem.repsToComplete = reps
                        try? modelContext.save()
                        dismiss()
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)
                    .accessibilityLabel("Save changes")                }
                .buttonStyle(.plain)
            }
			
			ToolbarItem(placement: .topBarLeading) {
				Button(role: .cancel) {
					dismiss()
				} label: {
                    Image(systemName: "x.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Cancel and return to set list view")
				}
				.buttonStyle(.plain)
			}
        }
    }
}

#Preview {
    @Previewable @State var item = PlaylistItem.sampleData[0]
    
    EditExerciseView(playlistItem: item)
}
