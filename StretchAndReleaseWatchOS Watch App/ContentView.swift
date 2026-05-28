//
//  ContentView.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(Managers.self) var managers
    
    // Properties stored in UserDefaults
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    @AppStorage("promptVolume") private var promptVolume = 1.0
    @AppStorage("playlist") private var isPlaylistActive = true
    
    // state variables used across views
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var endAngle = Angle(degrees: 340)
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // state variables only used on main view
    @State private var isShowingSettings = false
    @State private var didSettingsChange = false
	@State private var offset: CGFloat = 0
    
    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    // playlist properties
    @State var playlistItem: PlaylistItem?
    @State private var currentIndex = 0
    @State private var isPlaylistInactive = true
    
	//local properties for display
	var timerTextLabel: String {
        if !managers.isTimerPaused {
            playlistItem?.name ?? managers.stretchPhase.phaseText
        } else {
            "PAUSED"
        }
	}
    
    var displayColor: Color {
        if !managers.isTimerPaused {
            managers.stretchPhase.phaseColor
        } else {
            Color.gray
        }
    }
	
	var dragAccessibilityHint: String {
		if isPlaylistActive {
			"Drag to the left to go to the next stretch.  Drag to the right to go to the previous exercise."
		} else {
			"This is the current stretch phase."
		}
	}
    
    //Connectivity class for communication with phone
    @State private var connectivity = Connectivity()    
    
    var body: some View {
        NavigationStack {
            ZStack {
				TabView {
					Tab {
						TimerActionViewWatch()
					}
					Tab {
						PlaylistViewWatch()
					}
				}
//						VStack {
//							Color.gray.opacity(0)
//							
//							ZStack {
//								Color.gray.opacity(0)
//								
//								ZStack {
//									Arc(endAngle: endAngle)
//										.stroke(displayColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
//										.rotationEffect(Angle(degrees: 90))
//									
//									VStack {
//										Text("\(String(format: "%02d", Int(timeRemaining)))")
//											.font(.largeTitle)
//											.kerning(2)
//											.contentTransition(.numericText(countsDown: true))
//											.accessibilityLabel("\(timeRemaining) seconds remaining")
//											.padding(.bottom)
//										
//										//convert this to a grid to make the name section fixed width?
//										Grid {
//											GridRow {
//												HStack {
//													if isPlaylistActive {
//														Button {
//															currentIndex -= 1
//															if currentIndex < 0 {
//																currentIndex = playlist.count - 1
//															}
//															loadPlaylistItem(currentIndex)
//														} label: {
//															Image(systemName: "arrowtriangle.left.fill")
//																.foregroundStyle(.white)
//														}
//														.buttonStyle(.plain)
//														.accessibilityLabel("Go to the previous stretch")
//														.accessibilityInputLabels(["previous", "previous stretch"])
//													} else {
//														Color.clear
//													}
//												}
//												.frame(width: 15)
//												
//												Text(timerTextLabel)
//													.frame(width: 120)
//													.lineLimit(1)
//													.minimumScaleFactor(0.5)
//													.offset(x: offset)
//													.transition(.slide)
//													.gesture(
//														DragGesture()
//															.onEnded { gesture in
//																if isPlaylistActive {
//																	if gesture.translation.width < 0 {
//																		currentIndex -= 1
//																		if currentIndex < 0 {
//																			currentIndex = playlist.count - 1
//																		}
//																	} else if gesture.translation.width > 0 {
//																		currentIndex += 1
//																		if currentIndex == playlist.count {
//																			currentIndex = 0
//																		}
//																	}
//																	withAnimation(.linear(duration: 0.25)) {
//																		loadPlaylistItem(currentIndex)
//																	}
//																}
//															}
//													)
//													.accessibilityLabel(timerTextLabel)
//													.accessibilityHint(dragAccessibilityHint)
//												
//												HStack {
//													if isPlaylistActive {
//														Button {
//															currentIndex += 1
//															if currentIndex == playlist.count {
//																currentIndex = 0
//															}
//															loadPlaylistItem(currentIndex)
//														} label: {
//															Image(systemName: "arrowtriangle.right.fill")
//																.foregroundStyle(.white)
//														}
//														.buttonStyle(.plain)
//														.accessibilityLabel("Go to the next stretch")
//														.accessibilityInputLabels(["next", "next stretch"])
//													} else {
//														Color.clear
//													}
//												}
//												.frame(width: 15)
//												
//											}
//											.frame(height: 25)
//										}
//										
//										Text("Reps: \(repsCompleted)/\(totalReps)")
//											.accessibilityLabel("Repetitions Completed \(repsCompleted) of \(totalReps)")
//									}
//									.font(.caption)
//									.fontWeight(.bold)
//									.foregroundStyle(displayColor)
//								}
//								.sensoryFeedback(.impact(intensity: haptics ? managers.stretchPhase.phaseIntensity : 0.0), trigger: endAngle)
//							}
//							.containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
//								length * 0.9
//							}
//							.containerRelativeFrame(.vertical, alignment: .center) { length, _ in
//								length * 0.96
//							}
//							
//						}
                    }
                }
                .sheet(isPresented: $isShowingSettings) {
                    TimerSettingsViewWatch(didSettingsChange: $didSettingsChange)
                }
                
                //stops and resets tiner when settings view is toggled
                .onChange(of: isShowingSettings) {
                    withAnimation(.smooth(duration: 1)) {
                        managers.stopTimer()
                        timeRemaining = totalStretch
                        repsCompleted = 0
                        endAngle = Angle(degrees: 340)
                    }
                }
                
                //receives changed settings from iOS app
                .onChange(of: connectivity.didStatusChange) {
                    totalStretch = connectivity.statusContext["stretch"] as? Int ?? 10
                    totalRest = connectivity.statusContext["rest"] as? Int ?? 5
                    totalReps = connectivity.statusContext["reps"] as? Int ?? 5
                    connectivity.didStatusChange = false
                }
                
                //sends updated settings to iOS app
                .onChange(of: didSettingsChange) {
                    sendContext(stretch: totalStretch, rest: totalRest, reps: totalReps)
                    didSettingsChange = false
                }
                
                //when user changes totalStretch in SettingsView, force timeRemaining to reset to TotalStretch
                .onChange(of: totalStretch) {
                    timeRemaining = totalStretch
                }
                
                .onAppear() {
                    //prep audio tick sound
                    SoundManager.instance.prepareTick(sound: .tick)
                    SoundManager.instance.volume = promptVolume
					
					//load first playlist item, if playlist is active
					if isPlaylistActive {
						if !playlist.isEmpty {
							currentIndex = 0
							playlistItem = playlist[currentIndex]
							if let playlistItem {
								totalStretch = playlistItem.stretchDuration ?? 10
								totalRest = playlistItem.restDuration ?? 5
								totalReps = playlistItem.repsToComplete ?? 3
							}
						} else {
							playlistItem = nil
							isPlaylistActive = false
						}
					} else {
						timeRemaining = totalStretch
						repsCompleted = 0
						managers.stretchPhase = .stop
					}
                    //sets timeRemaining to totalStretch
                    timeRemaining = totalStretch
                }
        ._statusBarHidden()
    }
	
    //sends updated settings to iPhone
    func sendContext(stretch: Int, rest: Int, reps: Int) {
        let settingsUpdate = ["stretch" : stretch, "rest" : rest, "reps" : reps]
        connectivity.setContext(to: settingsUpdate)
    }
}

#Preview {
    ContentView()
		.modelContainer(previewContainer)
		.environment(Managers())
}

