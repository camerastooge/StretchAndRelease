//
//  TimerDisplayViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 3/20/26.
//

import SwiftUI
import SwiftData

struct TimerDisplayViewWatch: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.scenePhase) var scenePhase
    @Environment(Managers.self) var managers
    
    @StateObject var stretchSession = StretchSession()
    
    //Propertires stored in UserDefaults
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    @AppStorage("promptVolume") private var promptVolume = 1.0
    @AppStorage("playlist") private var isPlaylistActive = true
    
    //SwiftData models
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
	
	//playlist properties
	@State private var playlistItem: PlaylistItem?
	@State private var isPlaylistInactive = false
    
    //State variables used across views
    @State private var endAngle = Angle(degrees: 340)
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    @Binding var timeRemaining: Int
    @Binding var repsCompleted: Int
    @Binding var didSettingsChange: Bool
	@Binding var currentIndex: Int
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .watch
	
	//display string
	var displayString: String {
		guard !managers.isTimerPaused else { return "PAUSED" }
		
		if isPlaylistActive {
			return playlistItem?.name ?? managers.stretchPhase.phaseText
		} else {
			return managers.stretchPhase.phaseText
		}
	}
    
    var body: some View {
        VStack {
            //Timer Information Display
            ZStack {
                Arc(endAngle: endAngle)
                    .stroke(managers.stretchPhase.phaseColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(Angle(degrees: 90))
                    .sensoryFeedback(.impact(intensity: managers.stretchPhase.phaseIntensity), trigger: endAngle) { oldValue, newValue in
                        return haptics
                    }
                
                VStack {
                    Text("\(String(format: "%02d", Int(timeRemaining)))")
                        .font(.largeTitle)
                        .kerning(2)
                        .contentTransition(.numericText(countsDown: true))
                        .accessibilityLabel("\(timeRemaining) seconds remaining")
                    Text(displayString)
                        .scaleEffect(0.75)
                        .accessibilityLabel(!managers.isTimerPaused ? managers.stretchPhase.phaseText : "WORKOUT PAUSED")
                    Text("Reps: \(repsCompleted)/\(totalReps)")
                        .accessibilityLabel("Repetitions Completed \(repsCompleted) of \(totalReps)")
                }
            }
            .containerRelativeFrame([.horizontal, .vertical]) { length, axis in
                if axis == .vertical {
                    return length * 0.8
                } else {
                    return length * 0.95
                }
            }
            //this modifier runs when the timer publishes
            .onReceive(timer) { _ in
                if managers.isTimerActive && !managers.isTimerPaused {
                    switch managers.stretchPhase {
                    case .stretch: return {
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                            withAnimation(.linear(duration: 1.0)) {
                                endAngle = managers.updateEndAngle(timeRemaining: timeRemaining, totalTime: totalStretch)
                            }
                            if audio {
                                SoundManager.instance.playTick(sound: .tick)
                            }
                        } else {
                            repsCompleted += 1
                            if repsCompleted < totalReps {
                                withAnimation(.linear(duration: 0.5)) {
                                    managers.stretchPhase = .rest
                                }
                                if audio {
                                    SoundManager.instance.playPrompt(sound: .rest)
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    managers.stretchPhase = .stop
                                }
                                timeRemaining = totalStretch
                                withAnimation(.easeOut(duration: 1.0)) {
                                    endAngle = managers.updateEndAngle(timeRemaining: timeRemaining, totalTime: totalStretch)
                                }
                                if audio {
                                    SoundManager.instance.playPrompt(sound: .relax)
                                }
                            }
                        }
                    }()
                        
                    case .rest: return {
                        if timeRemaining < totalRest {
                            timeRemaining += 1
                            withAnimation(.easeOut(duration: 1.0)) {
                                endAngle = managers.updateEndAngle(timeRemaining: timeRemaining, totalTime: totalRest)
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.5)) {
                                managers.stretchPhase = .stretch
                            }
                            timeRemaining = totalStretch
                            if audio {
                                SoundManager.instance.playPrompt(sound: .stretch)
                            }
                        }
                    }()
                        
                    case .stop: return {
                        managers.isTimerActive = false
                        stretchSession.stop()
                    }()
                    }
                }
            }
			.onChange(of: currentIndex) {
				loadPlaylistItem(currentIndex)
			}
			.onAppear {
				loadPlaylistItem(currentIndex)
				timeRemaining = totalStretch
			}
        }
    }
	
	//load playlistItem from currentIndex
	func loadPlaylistItem(_ index: Int) {
		playlistItem = playlist[index]
		if let playlistItem {
			totalStretch = playlistItem.stretchDuration ?? 10
			totalRest = playlistItem.restDuration ?? 5
			totalReps = playlistItem.repsToComplete ?? 3
		}
	}
}

#Preview {
    @Previewable @State var timeRemaining = 0
    @Previewable @State var repsCompleted = 0
    @Previewable @State var isShowingSettings = false
    @Previewable @State var didSettingsChange = false
	@Previewable @State var currentIndex = 0
    
	TimerDisplayViewWatch(timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, didSettingsChange: $didSettingsChange, currentIndex: $currentIndex)
        .environment(Managers())
        .modelContainer(previewContainer)
}
