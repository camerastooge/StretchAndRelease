//
//  PlaylistView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/26/26.
//

import SwiftUI
import SwiftData

struct PlaylistView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // Properties stored in UserDefaults
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    //SwiftData property
    @Query var playlist: [PlaylistItem]
    
    //State properties
    @State private var isShowingAddExercise = false
    @State private var name: String = ""
    @State private var stretchDuration: Int = 0
    @State private var restDuration: Int = 0
    @State private var repsNumber: Int = 0
    
    @State private var isShowingActive = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(playlist) { exercise in
                    PlaylistRowView(item: exercise)
                }
            }
            .navigationTitle("Playlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowingAddExercise.toggle()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "plus.circle")
                                .glassEffect()
                                .foregroundStyle(.blue)
                                .accessibilityLabel("Add new exercise to playlist")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        } else {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.blue)
                                .accessibilityLabel("Add new exercise to playlist")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        }
                    }
                }
                
                if #available(iOS 26.0, *) {
                    ToolbarSpacer()
                }
                
                ToolbarItem {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "x.circle")
                                .glassEffect()
                                .foregroundStyle(.red)
                                .accessibilityLabel("Return to main screen")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        } else {
                            Image(systemName: "x.circle.fill")
                                .tint(.red)
                                .accessibilityLabel("Return to main screen")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddExercise) {
                AddExerciseToPlaylistView()
            }
        }
    }
}

#Preview {
    PlaylistView()
        .modelContainer(previewContainer)
}
