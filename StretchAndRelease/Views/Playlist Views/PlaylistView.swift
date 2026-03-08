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
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                modelContext.delete(exercise)
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .accessibilityLabel("Delete \(exercise.name)")
                                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            NavigationLink {
                                EditExerciseView(playlistItem: exercise)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .accessibilityLabel("Change settings for \(exercise.name)")
                                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            }
                            .tint(.blue)
                        }
                }
                .onMove(perform: move)
            }
            .navigationTitle("Playlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        AddExerciseView()
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
        }
    }
}

extension PlaylistView {
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
    PlaylistView()
        .modelContainer(previewContainer)
}
