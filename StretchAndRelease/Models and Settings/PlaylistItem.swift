//
//  PlaylistItem.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/26/26.
//

import Foundation
import SwiftData

@Model
class PlaylistItem {
    //system defined properties
    var id = UUID()
    var active = false
    var placeInList = 0
    
    //user defined properties
    var name: String
    var stretchDuration: Int
    var restDuration: Int
    var repsToComplete: Int
    
    init(name: String, stretchDuration: Int, restDuration: Int, repsToComplete: Int) {
        self.name = name
        self.stretchDuration = stretchDuration
        self.restDuration = restDuration
        self.repsToComplete = repsToComplete
    }
}

extension PlaylistItem {
    static var sampleData: [PlaylistItem] {
        [
            PlaylistItem(name: "Upward reach", stretchDuration: 10, restDuration: 4, repsToComplete: 5),
            PlaylistItem(name: "Left reach", stretchDuration: 6, restDuration: 5, repsToComplete: 4),
            PlaylistItem(name: "Right reach", stretchDuration: 6, restDuration: 5, repsToComplete: 4),
            PlaylistItem(name: "Downward reach", stretchDuration: 6, restDuration: 4, repsToComplete: 5)
        ]
    }
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: PlaylistItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        for item in PlaylistItem.sampleData {
            container.mainContext.insert(item)
        }
        
        return container
    } catch {
        fatalError("failed to create preview container")
    }
}()

