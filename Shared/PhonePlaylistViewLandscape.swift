//
//  PhonePlaylistViewLandscape.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/12/26.
//

import SwiftUI
import SwiftData

struct PhonePlaylistViewLandscape: View {
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
    
    //Define columns for LazyVGrid
    private let playlistColumns: [GridItem] = [
        GridItem(.flexible(minimum: 150), alignment: .leading),
        GridItem(.fixed(60), alignment: .center),
        GridItem(.fixed(60), alignment: .center),
        GridItem(.fixed(70), alignment: .center),
    ]
    
    @State private var isShowingActive = false

    //The manager SwiftData actually registers against.
    private var undoManager: UndoManager? { modelContext.undoManager }
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}



#Preview {
    PhonePlaylistViewLandscape()
        .modelContainer(previewContainer)
//        .modelContainer(for: PlaylistItem.self)
}
