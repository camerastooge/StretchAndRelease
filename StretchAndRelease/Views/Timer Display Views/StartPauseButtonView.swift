//
//  StartPauseButtonView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 3/12/26.
//

import SwiftUI
import SwiftData

struct StartPauseButtonView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(Managers.self) var managers
    
    // Properties stored in UserDefaults
    @AppStorage("stretch")          private var totalStretch = 10
    @AppStorage("rest")             private var totalRest = 5
    @AppStorage("reps")             private var totalReps = 3
    
    @AppStorage("audio")            private var audio = true
    @AppStorage("haptics")          private var haptics = true
    @AppStorage("promptVolume")     private var promptVolume = 1.0
    @AppStorage("playlist")         private var isPlaylistActive = false
    @AppStorage("currentIndex")     private var currentIndex: Int?
    
    // state variables used across views
    @Binding var repsCompleted: Int
    
    // SwiftData model and item for current playlist item
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    var playlistItem: PlaylistItem?
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .phone
    
    
    var body: some View {
        Button {
            //engage from full stop
            if managers.stretchPhase == .stop {
                if audio {
                    SoundManager.instance.playPrompt(sound: .countdownExpanded)
                }
                
                DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3 : .now() + 0.5) {
                    withAnimation(.linear(duration: 0.25)) {
                        managers.startTimer()
                        repsCompleted = 0
                    }
                }
            }
            
            //pause the timer
            else if !managers.isTimerPaused {
                managers.isTimerActive = false
                managers.isTimerPaused = true
            }
            
            //un-pause the timer
            else {
                if audio {
                    SoundManager.instance.playPrompt(sound: .countdown)
                }
                DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3 : .now() + 0.5) {
                    withAnimation(.linear(duration: 0.25)) {
                        managers.isTimerActive = true
                        managers.isTimerPaused = false
                    }
                }
                
            }
        } label: {
            ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
        }
    }
    
    func loadPlaylistItem() {
        if let currentIndex {
            let item = playlist[currentIndex]
            playlistItem?.name = item.name
            playlistItem?.stretchDuration = item.stretchDuration
            playlistItem?.restDuration = item.restDuration
            playlistItem?.repsToComplete = item.repsToComplete
        }
    }
}

#Preview {
    @Previewable @State var repsCompleted = 0
    
    StartPauseButtonView(repsCompleted: $repsCompleted)
        .environment(Managers())
}
