//
//  TimerButtonRowViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 3/21/26.
//

import SwiftUI
import SwiftData

struct TimerButtonRowViewWatch: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.scenePhase) var scenePhase
    @Environment(Managers.self) var managers
    
    //Stretch session
    @ObservedObject var stretchSession: StretchSession
    
    //AppStorage properties
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    @AppStorage("promptVolume") private var promptVolume = 1.0
    @AppStorage("playlist") private var isPlaylistActive = true
    
    //Binding properties
    @Binding var timeRemaining: Int
    @Binding var repsCompleted: Int
    @Binding var didSettingsChange: Bool
    @Binding var currentIndex: Int
    @Binding var endAngle: Angle
    
    //SwiftData models
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .watch
    
    //Local State properties
    @State private var isResetToggled: Bool

    
    var body: some View {
        //Button row
        ScrollView {
            VStack {
                //top row
                HStack {
                    //Either reset button or previous exercise
                    if isPlaylistActive {
                        Button {
                            currentIndex -= 1
                            if currentIndex < 0 {
                                currentIndex = playlist.count - 1
                            }
                        } label: {
                            ButtonView(buttonRoles: .previousItem, deviceType: deviceType)
                                .opacity(0.75)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing)
                        .accessibilityInputLabels(["Previous Stretch"])
                        .accessibilityLabel("Go to the previous stretch on the set list")
                    } else {
                        Button {
                            withAnimation(.linear(duration: 0.25)) {
                                managers.isTimerActive = false
                                managers.isTimerPaused = false
                                repsCompleted = 0
                                managers.stretchPhase = .stop
                                timeRemaining = totalStretch
                                stretchSession.stop()
                            }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                endAngle = managers.updateEndAngle(timeRemaining: timeRemaining, totalTime: totalStretch)
                            }
                        } label: {
                            ButtonView(buttonRoles: .reset, deviceType: deviceType)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing)
                        .accessibilityInputLabels(["Reset", "Reset Timer"])
                        .accessibilityLabel("Reset Timer")
                    }
                    
                    Spacer()
                    
                    //Play-pause button
                    Button {
                        withAnimation {
                            if managers.stretchPhase == .stop {
                                withAnimation(.linear(duration: 0.5)) {
                                    managers.stretchPhase = .stretch
                                }
                                
                                stretchSession.start()
                                
                                if audio {
                                    SoundManager.instance.playPrompt(sound: .countdownExpanded)
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3 : .now() + 0.5) {
                                    managers.isTimerActive = true
                                    managers.isTimerPaused = false
                                    repsCompleted = 0
                                    
                                }
                            } else if !managers.isTimerPaused {
                                withAnimation(.linear(duration: 0.25)) {
                                    managers.isTimerPaused = true
                                    managers.isTimerActive = false
                                }
                            } else {
                                if audio {
                                    SoundManager.instance.playPrompt(sound: .countdownExpanded)
                                }
                                DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3 : .now() + 0.5) {
                                    withAnimation(.linear(duration: 0.25)) {
                                        managers.isTimerPaused = false
                                        managers.isTimerActive = true
                                    }
                                }
                            }
                        }
                    } label: {
                        ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
                        
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing)
                    .accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
                    .accessibilityLabel(managers.stretchPhase != .stretch ? "Start the Timer" : "Pause the Timer")
                    .accessibilityHint("Press to start or pause the timer.  Long press to reset the timer to its starting point.")
                    .onLongPressGesture(minimumDuration: 0.5) {
                        if managers.isTimerPaused {
                            withAnimation(.linear(duration: 0.25)) {
                                managers.isTimerPaused = true
                                managers.isTimerActive = false
                            }
                        }
                        isResetToggled.toggle()
                    }
                    
                    Spacer()
                    
                    //Next exercise button
                    if isPlaylistActive {
                        Button {
                            currentIndex += 1
                            if currentIndex == playlist.count {
                                currentIndex = 0
                            }
                        } label: {
                            ButtonView(buttonRoles: .nextItem, deviceType: deviceType)
                                .opacity(0.75)
                        }
                        .buttonStyle(.plain)
                        .accessibilityInputLabels(["Next Stretch"])
                        .accessibilityLabel("Go to the next stretch on the set list")
                    }
                 }
            }
            .padding([.horizontal, .top])
            .containerRelativeFrame(.horizontal)
            .dynamicTypeSize(DynamicTypeSize.xxxLarge)
        }
        .scrollDisabled(true)
        .containerRelativeFrame(.horizontal)
        .alert("Reset Timer?", isPresented: $isResetToggled) {
            if #available(watchOS 26.0, *) {
                Button("OK", role: .confirm) {
                    resetTimer()
                }
            } else {
                Button("OK") {
                    resetTimer()
                }
            }
            
            Button("Cancel", role: .cancel) {
                if managers.isTimerPaused {
                    unPauseTimer()
                }
            }
        } message: {
            Text("Stop the timer and reset your stretch?")
        }
    }
    
    func resetTimer() {
        withAnimation(.linear(duration: 0.25)) {
            managers.isTimerActive = false
            managers.isTimerPaused = false
            repsCompleted = 0
            managers.stretchPhase = .stop
            timeRemaining = totalStretch
            stretchSession.stop()
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            endAngle = managers.updateEndAngle(timeRemaining: timeRemaining, totalTime: totalStretch)
        }
    }
    
    func unPauseTimer() {
        if audio {
            SoundManager.instance.playPrompt(sound: .countdownExpanded)
        }
        DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 3 : .now() + 0.5) {
            withAnimation(.linear(duration: 0.25)) {
                managers.isTimerPaused = false
                managers.isTimerActive = true
            }
        }
    }
}

#Preview {
    @Previewable @State var timeRemaining = 0
    @Previewable @State var repsCompleted = 0
    @Previewable @State var isShowingSettings = false
    @Previewable @State var didSettingsChange = false
    @Previewable @State var currentIndex = 0
    @Previewable @State var endAngle = Angle(degrees: 340)
    @Previewable @State var isResetToggled = false
    
    TimerButtonRowViewWatch(stretchSession: StretchSession(), timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, didSettingsChange: $didSettingsChange, currentIndex: $currentIndex, endAngle: $endAngle, isResetToggled: isResetToggled)
        .environment(Managers())
}
