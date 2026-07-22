//
//  AddExerciseView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 3/8/26.
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    
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
    @State private var isExerciseAddedToEmptyPlaylist = false
    
    @ScaledMetric var buttonWidth = 100
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.gradientBackground()
                
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
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Name Field Is Empty", isPresented: $isShowingEmptyNameField) {
                Button("OK", role: .cancel) {
                    isShowingEmptyNameField = false
                }
            } message: {
                Text("You must name your exercise.")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if !name.isEmpty {
                            let playlistItem = PlaylistItem(index: playlist.isEmpty ? 0 : playlist.count + 1, name: name, stretchDuration: stretch, restDuration: rest, repsToComplete: reps)
                            modelContext.insert(playlistItem)
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
                        if #available(iOS 26.0, *) {
                            Image(systemName: "chevron.left")
                                .glassEffect(.clear)
                                .accessibilityLabel("Save changes and return to set list view")
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
}

#Preview {
    AddExerciseView()
}
