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
    @AppStorage("playlist") private var isPlaylistActive = false
    
    //SwiftData property
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    //State properties
    @State private var name: String = ""
    @State private var stretchDuration: Int = 0
    @State private var restDuration: Int = 0
    @State private var repsNumber: Int = 0
    
    //Checks for determining playlist status
    @State private var isPlaylistInactive = false
    @State private var playlistHasBeenEmptied = false
    
    //Define columns for LazyVGrid
    private let playlistColumns: [GridItem] = [
        GridItem(.flexible(minimum: 150), alignment: .leading),
        GridItem(.fixed(60), alignment: .center),
        GridItem(.fixed(60), alignment: .center),
        GridItem(.fixed(70), alignment: .center),
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
                                .listRowBackground(Color.clear)
                            }
                            .onMove(perform: move)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .safeAreaInset(edge: .bottom) {
                        NavigationLink {
                            AddExerciseView()
                        } label: {
                            Text("ADD")
                                .frame(width: 200, height: 65)
                                .font(.system(size: 32))
                                .fontWeight(.bold)
                                .shadow(color: .gray, radius: 0.2, x: 0.5, y: 1)
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
            .onChange(of: playlist) {
                if playlist.isEmpty {
                    playlistHasBeenEmptied = true
                    isPlaylistActive = false
                } else {
                    if !isPlaylistActive {
                        isPlaylistInactive = true
                    }
                }
            }
            .alert("Set List is Not Active", isPresented: $isPlaylistInactive) {
                if #available(iOS 26.0, *) {
                    Button("OK", role: .confirm) {
                        isPlaylistActive = true
                    }
                    
                    Button("Cancel", role: .cancel) { }
                    .backgroundStyle(Color.red)
                } else {
                    Button("OK") {
                        isPlaylistActive = true
                    }
                    
                    Button(role: .cancel) { } label: {
                        Text("Cancel")
                            .backgroundStyle(Color.red)
                    }
                }
            } message: {
                Text("Do you want to turn the set list on?")
            }
            .alert("Set list has been turned off", isPresented: $playlistHasBeenEmptied) {
                if #available(iOS 26.0, *) {
                    Button("OK", role: .confirm) {
                        isPlaylistActive = false
                    }
                } else {
                    Button("OK") {
                        isPlaylistActive = false
                    }
                }
            } message: {
                Text("The set list has been turned off since it is empty.")
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

struct playlistHeaderView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var columns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Text("Name")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? .secondary : Color.white.opacity(0.7))
                .lineLimit(1)
                .padding(.leading, 5)
                .accessibilityLabel("Name")
                .accessibilityHint("The name of the selected sretch")
            
            Text(sizeCategory >= .xLarge ? "S" : "Stretch")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.green)
                .lineLimit(1)
                .accessibilityLabel("Stretch Duration")
                .accessibilityHint("The length of time to hold the selected stretch")
            
            Text(sizeCategory >= .xLarge ? "R" : "Rest")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.yellow)
                .lineLimit(1)
                .accessibilityLabel("Rest Duration")
                .accessibilityHint("The length of time to rest between stretches")
            
            Text(sizeCategory >= .xLarge ? "R" : "Reps")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.red)
                .lineLimit(1)
                .accessibilityLabel("Number of repetitions")
                .accessibilityHint("How many times to perform this stretch in the set")
        }

    }
}

#Preview {
    PlaylistView()
        .modelContainer(previewContainer)
}
