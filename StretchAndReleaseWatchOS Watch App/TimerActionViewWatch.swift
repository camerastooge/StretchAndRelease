//
//  TimerActionViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 5/27/26.
//

import SwiftUI
import SwiftData
import Combine

struct TimerActionViewWatch: View {
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
	@AppStorage("playlist") private var isPlaylistActive = false
	
	// state variables used across views
	@State private var repsCompleted: Int = 0
	@State private var endAngle = Angle(degrees: 340)
	let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
	
	// state variables only used on main view
	@Binding var timeRemaining: Int
	@Binding var isShowingSettings: Bool
	
    @State private var didSettingsTriggerFromContentView = true
	@State private var didSettingsChange = false
	@State private var offset: CGFloat = 0
	
	//SwiftData query
	@Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
	
	// playlist properties
	@State var playlistItem: PlaylistItem?
    @State private var playlistIndex: Int? = 0
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
	
	// variables for button view
	var buttonRoles: ButtonRoles = .play
	var deviceType: DeviceType = .watch

	
    var body: some View {
		ZStack {
			Color.gray.opacity(0)
			
			ZStack {
				Arc(endAngle: endAngle)
					.stroke(displayColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
					.rotationEffect(Angle(degrees: 90))
				
				VStack {
					Text("\(String(format: "%02d", Int(timeRemaining)))")
						.font(.largeTitle)
						.kerning(2)
						.contentTransition(.numericText(countsDown: true))
						.accessibilityLabel("\(timeRemaining) seconds remaining")
						.padding(.bottom, 5)
					
					Grid {
						GridRow {
							HStack {
								if isPlaylistActive {
									Button {
                                        guard var playlistIndex else { return }
										playlistIndex -= 1
										if playlistIndex < 0 {
											playlistIndex = playlist.count - 1
										}
                                        self.playlistIndex = playlistIndex
										loadPlaylistItem(playlistIndex)
									} label: {
										Image(systemName: "arrowtriangle.left.fill")
											.foregroundStyle(.white)
									}
									.buttonStyle(.plain)
									.accessibilityLabel("Previous stretch")
									.accessibilityInputLabels(["previous", "previous stretch"])
								} else {
									Color.clear
								}
							}
							.frame(width: 15)
							
							Text(timerTextLabel)
								.frame(width: 90)
								.lineLimit(1)
								.minimumScaleFactor(0.5)
								.offset(x: offset)
								.transition(.slide)
								.gesture(
										DragGesture()
											.onEnded { gesture in
												if isPlaylistActive {
                                                    guard var playlistIndex else { return }
													if gesture.translation.width < 0 {
														playlistIndex -= 1
														if playlistIndex < 0 {
															playlistIndex = playlist.count - 1
														}
													} else if gesture.translation.width > 0 {
														playlistIndex += 1
														if playlistIndex == playlist.count {
															playlistIndex = 0
														}
													}
                                                    self.playlistIndex = playlistIndex
													withAnimation(.linear(duration: 0.25)) {
														loadPlaylistItem(playlistIndex)
													}
												}
											}
										)
								.accessibilityLabel(timerTextLabel)
								.accessibilityHint(dragAccessibilityHint)
							
							HStack {
								if isPlaylistActive {
									Button {
                                        guard var playlistIndex else { return }
										playlistIndex += 1
										if playlistIndex == playlist.count {
											playlistIndex = 0
										}
                                        self.playlistIndex = playlistIndex
										loadPlaylistItem(playlistIndex)
									} label: {
										Image(systemName: "arrowtriangle.right.fill")
											.foregroundStyle(.white)
									}
									.buttonStyle(.plain)
									.accessibilityLabel("Go to the next stretch")
									.accessibilityInputLabels(["next", "next stretch"])
								} else {
									Color.clear
								}
							}
							.frame(width: 15)

						}
						.frame(height: 20)
					}
					
					Text("Reps: \(repsCompleted)/\(totalReps)")
						.accessibilityLabel("Repetitions Completed \(repsCompleted) of \(totalReps)")
				}
				.font(.caption)
				.fontWeight(.bold)
				.foregroundStyle(displayColor)
			}
			.sensoryFeedback(.impact(intensity: haptics ? managers.stretchPhase.phaseIntensity : 0.0), trigger: endAngle)
			}
		.containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
			length * 0.8
		}
		.containerRelativeFrame(.vertical, alignment: .center) { length, _ in
			length * 0.86
		}
		.padding(.bottom, 12)
		
		
		//Button Row
		HStack {
			//play-pause button
			Button {
					// timer starting from full stop
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
                        managers.isTimerPaused = true
					}
                
                    //unpause the timer
                    else {
						if audio {
							SoundManager.instance.playPrompt(sound: .countdown)
						}
                        DispatchQueue.main.asyncAfter(deadline: audio ? .now() + 2.0 : .now() + 0.5) {
                            withAnimation(.linear(duration: 0.25)) {
                                managers.isTimerActive = true
                                managers.isTimerPaused = false
                            }
                        }
					}
			} label: {
                if #available(watchOS 26.0, *) {
                    ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
                        .glassEffect()
                } else {
                    ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
                }
			}
			.buttonStyle(.plain)
			.padding(.trailing)
			.accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
			.accessibilityLabel("Start or Pause Timer")
			
			//resets timer
			Button {
				managers.stopTimer()
				repsCompleted = 0
				timeRemaining = totalStretch
				withAnimation(.linear(duration: 0.5)) {
					updateEndAngle()
				}
			} label: {
                if #available(watchOS 26.0, *) {
                    ButtonView(buttonRoles: .reset, deviceType: deviceType)
                        .glassEffect()
                } else {
                    ButtonView(buttonRoles: .reset, deviceType: deviceType)
                }
			}
			.buttonStyle(.plain)
			.padding(.trailing)
			.accessibilityInputLabels(["Reset", "Reset Timer"])
			.accessibilityLabel("Reset Timer")
			
			//Settings
			NavigationLink {
                TimerSettingsViewWatch(didTriggerSettingsFromContentView: $didSettingsTriggerFromContentView)
					.navigationBarBackButtonHidden()
			} label: {
				if #available(watchOS 26.0, *) {
					ButtonView(buttonRoles: .settings, deviceType: deviceType)
						.glassEffect()
				} else {
					ButtonView(buttonRoles: .settings, deviceType: deviceType)
				}
				
			}
			.buttonStyle(.plain)
			.accessibilityLabel("show settings")
			.accessibilityInputLabels(["settings"])
		}
		.dynamicTypeSize(DynamicTypeSize.xxxLarge)
		.containerRelativeFrame(.vertical) { length, _ in
			length * 0.35
		}
		
        .onAppear {
            didSettingsTriggerFromContentView = true
        }
        
		.onChange(of: isPlaylistActive) {
			if isPlaylistActive {
                guard var playlistIndex else { return }
				if !playlist.isEmpty {
					playlistIndex = 0
					loadPlaylistItem(playlistIndex)
				} else {
					playlistItem = nil
					isPlaylistActive = false
				}
			} else {
				playlistItem = nil
			}
		}
		
		//when user changes totalStretch in SettingsView, force timeRemaining to reset to TotalStretch
		.onChange(of: totalStretch, initial: true) {
			timeRemaining = totalStretch
		}
		
		//this modifier runs when the timer publishes
		.onReceive(timer) { _ in
            switch managers.stretchPhase {
            case .stretch: return manageStretch()
            case .rest: return manageRest()
            case .stop: return manageStop()
            }
		}
    }
	
	//function to stop timer
	func timerFullStop() {
		if audio {
			SoundManager.instance.playPrompt(sound: .relax)
		}
		withAnimation(.easeOut(duration: 0.5)) {
			managers.stopTimer()
			updateEndAngle()
		}
		timeRemaining = totalStretch
	}
	
	//function to manage stretch portion of stretch
    func manageStretch() {
        //if timer is paused, stop the timer and wait
        if managers.isTimerPaused {
            managers.isTimerActive = false
        } else {
            if timeRemaining > 0 {
                timeRemaining -= 1
                withAnimation(.easeOut(duration: 1)) {
                    updateEndAngle()
                }
                if audio {
                    SoundManager.instance.playTick(sound: .tick)
                }
            } else {
                repsCompleted += 1
                if repsCompleted < totalReps {
                    if audio {
                        SoundManager.instance.playPrompt(sound: .rest)
                    }
                    withAnimation {
                        managers.stretchPhase = .rest
                    }
                } else {
                    if !isPlaylistActive {
                        timerFullStop()
                    } else {
                        if playlistIndex != playlist.count - 1 {
                            if audio {
                                SoundManager.instance.playPrompt(sound: .rest)
                            }
                            withAnimation {
                                managers.stretchPhase = .rest
                            }
                        } else {
                            timerFullStop()
                            playlistIndex = 0
                            loadPlaylistItem(playlistIndex ?? 0)
                        }
                    }
                }
            }
        }
    }
	
	//function to manage rest portion of stretch
    func manageRest() {
        if managers.isTimerPaused {
            if timeRemaining != totalRest {
                timeRemaining += 1
                withAnimation(.easeOut(duration: 1)) {
                    updateEndAngle()
                }
            } else {
                managers.isTimerActive = false
                if !isPlaylistActive {
                    timeRemaining = totalStretch
                    withAnimation(.easeOut(duration: 1)) {
                        managers.stretchPhase = .stretch
                        updateEndAngle()
                    }
                } else {
                    guard var playlistIndex else { return }
                    if repsCompleted != totalReps {
                        timeRemaining = totalStretch
                        managers.stretchPhase = .stretch
                        withAnimation(.easeOut(duration: 1)) {
                            updateEndAngle()
                        }
                        managers.isTimerActive = true
                    } else {
                        managers.stretchPhase = .stretch
                        repsCompleted = 0
                        playlistIndex += 1
                        loadPlaylistItem(playlistIndex)
                        timeRemaining = totalStretch
                        managers.isTimerActive = true
                    }
                }
            }
        } else {
            if timeRemaining != totalRest {
                timeRemaining += 1
                withAnimation(.easeOut(duration: 1)) {
                    updateEndAngle()
                }
            } else {
                if !isPlaylistActive {
                    timeRemaining = totalStretch
                    withAnimation {
                        managers.stretchPhase = .stretch
                    }
                    if audio {
                        SoundManager.instance.playPrompt(sound: .stretch)
                    }
                } else {
                    guard var playlistIndex else { return }
                    if repsCompleted == totalReps {
                        managers.stretchPhase = .stretch
                        repsCompleted = 0
                        playlistIndex += 1
                        loadPlaylistItem(playlistIndex)
                        timeRemaining = totalStretch
                    } else {
                        timeRemaining = totalStretch
                        withAnimation {
                            managers.stretchPhase = .stretch
                        }
                        if audio {
                            SoundManager.instance.playPrompt(sound: .stretch)
                        }
                    }
                }
            }
        }
    }
	
	//function to manage timer stop
	func manageStop() {
        withAnimation(.easeOut(duration: 0.5)) {
            managers.stretchPhase = .stop
            managers.isTimerActive = false
            managers.isTimerPaused = false
            updateEndAngle()
        }
	}
	
	//function to set end angle of arc
	func updateEndAngle() {
		switch managers.stretchPhase {
		case .stretch:
			endAngle = Angle(degrees: Double(timeRemaining) / Double(totalStretch) * 320 + 20)
		case .rest:
			endAngle = Angle(degrees: Double(timeRemaining) / Double(totalRest) * 320 + 20)
		case .stop:
			endAngle = Angle(degrees: 340)
		}
	}
	
	//load playlistItem values into timer properties
	func loadPlaylistItem(_ index: Int) {
		playlistItem = playlist[index]
		if let playlistItem {
			totalStretch = playlistItem.stretchDuration ?? 10
			totalRest = playlistItem.restDuration ?? 5
			totalReps = playlistItem.repsToComplete ?? 3
		}
		timeRemaining = totalStretch
	}
}

#Preview {
	@Previewable @State var isShowingSettings = false
	@Previewable @State var timeRemaining = 5
	
	TimerActionViewWatch(timeRemaining: $timeRemaining, isShowingSettings: $isShowingSettings)
        .environment(Managers())
		.modelContainer(previewContainer)
}
