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
            }
        }
        .onAppear {
            name = playlistItem.name ?? "Exercise"
            stretch = playlistItem.stretchDuration ?? 10
            rest = playlistItem.restDuration ?? 5
            reps = playlistItem.repsToComplete ?? 3
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    playlistItem.name = name
                    playlistItem.stretchDuration = stretch
                    playlistItem.restDuration = rest
                    playlistItem.repsToComplete = reps
                    try? modelContext.save()
                    dismiss()
                } label: {
                    if #available(iOS 26.0, *) {
                        Image(systemName: "chevron.left")
                            .glassEffect(.clear)
                    } else {
                        Image(systemName: "chevron.left")
                            .accessibilityLabel("Save changes and return to set list view")
                    }
                }
				.buttonStyle(.plain)
            }
			
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(role: .cancel) {
					dismiss()
				} label: {
					if #available(iOS 26.0, *) {
						Image(systemName: "x.circle")
							.glassEffect(.clear)
							.foregroundStyle(.red)
							.accessibilityLabel("Cancel and return to set list view")
					} else {
						Image(systemName: "x.circle.fill")
							.foregroundStyle(Color.red)
							.accessibilityLabel("Cancel and return to set list view")
					}
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
