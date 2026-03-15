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
    @State private var name: String = ""
    @State private var stretchDuration: Int = 0
    @State private var restDuration: Int = 0
    @State private var repsNumber: Int = 0
    
    //Define columns for LazyVGrid
    private let playlistColumns: [GridItem] = [
        GridItem(.flexible(minimum: 150), alignment: .leading), // name
        GridItem(.fixed(60), alignment: .center),               // stretch
        GridItem(.fixed(60), alignment: .center),               // rest
        GridItem(.fixed(70), alignment: .center),               // reps
    ]
    
    @State private var isShowingActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.gradientBackground()
                
                if !playlist.isEmpty {
                    List {
                        Section(header: playlistHeaderView(columns: playlistColumns)) {
                            ForEach(playlist) { exercise in
                                NavigationLink {
                                    EditExerciseView(playlistItem: exercise)
                                } label: {
                                    PlaylistRowView(item: exercise, columns: playlistColumns)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button {
                                                modelContext.delete(exercise)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                                    .tint(.red)
                                                    .accessibilityLabel("Delete \(exercise.name)")
                                                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                            }
                                        }
                                }
                                .navigationLinkIndicatorVisibility(.hidden)
                                .accessibilityLabel("Edit \(exercise.name)")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
//                                .listRowBackground(Color.clear)
                            }
                            .onMove(perform: move)
                        }
                    }
                    .listStyle(.plain)
//                    .scrollContentBackground(.hidden)
                    .safeAreaInset(edge: .bottom) {
                        NavigationLink {
                            AddExerciseView()
                        } label: {
                            Text("ADD")
                                .frame(width: 200, height: 65)
                                .font(.system(size: 32))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .background(.green)
                                .clipShape(.capsule)
                                .padding(.bottom, 5)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        }
                        .accessibilityLabel("Add exercise")
                        .accessibilityHint("Add an exercise to the playlist")
                    }
                } else {
                    ContentUnavailableView {
                        Label("Playlist is Empty", systemImage: "plus.circle")
                            .font(.largeTitle)
                            .padding(.bottom)
                    } description: {
                        Text("Press ADD to add a stretch to your playlist")
                            .font(.system(size: 24))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    .safeAreaInset(edge: .bottom) {
                        NavigationLink {
                            AddExerciseView()
                        } label: {
                            Text("ADD")
                                .frame(width: 200, height: 65)
                                .font(.system(size: 32))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .background(.green)
                                .clipShape(.capsule)
                                .padding(.bottom, 5)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        }
                        .accessibilityLabel("Add exercise")
                        .accessibilityHint("Add an exercise to the playlist")
                    }
                }

            }
            .navigationTitle("Playlist")
            .navigationBarTitleDisplayMode(.inline)
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

struct playlistHeaderView: View {
    var columns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Text("Name")
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .padding(.leading, 5)
            
            Text("Stretch")
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Text("Rest")
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Text("Reps")
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
        }

    }
}

#Preview {
    PlaylistView()
        .modelContainer(previewContainer)
}
