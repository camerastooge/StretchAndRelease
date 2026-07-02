//
//  TimerDisplayView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 3/10/26.
//

import SwiftUI
import SwiftData
import Combine

struct TimerDisplayView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
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
    @State private var timeRemaining: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var endAngle = Angle(degrees: 340)
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    // local properties
	@Binding var playlistIndex: Int?
    @Binding var playlistItem: PlaylistItem?
    
    // variables for button view
    var buttonRoles: ButtonRoles = .play
    var deviceType: DeviceType = .phone
	var timerTextLabel: String {
		if isPlaylistActive {
			guard let playlistItem else { return managers.stretchPhase.phaseText }
			return playlistItem.name ?? managers.stretchPhase.phaseText
		} else {
			if managers.isTimerPaused {
				return "PAUSED"
			} else {
				return managers.stretchPhase.phaseText
			}
		}
	}
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear.gradientBackground()
            
            VStack(spacing: 0) {
                ZStack {
                    MainArcView(endAngle: $endAngle, timeRemaining: $timeRemaining, totalReps: $totalReps, repsCompleted: $repsCompleted, timerTextLabel: timerTextLabel)
                        
                }
                .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                    length * 0.9
                }
                .frame(minHeight: 0, maxHeight: .infinity)
                .layoutPriority(1)
                
                // playlist button row
                if isPlaylistActive {
                    ZStack {
                        Color.gray.opacity(differentiateWithoutColor ? 0 : 0.25)
                        HStack {
                            Spacer()
                            
                            //PREVIOUS EXERCISE BUTTON
                            Button {
                                guard var playlistIndex else { return }
								playlistIndex -= 1
                                if playlistIndex < 0 {
                                    playlistIndex = playlist.count - 1
                                }
								self.playlistIndex = playlistIndex
                                loadPlaylistItem(playlistIndex)
                            } label: {
                                ButtonView(buttonRoles: .previousItem, deviceType: deviceType)
                                    .opacity(0.75)
                            }
                            .accessibilityLabel("Go to previous item in set list")
							.accessibilityInputLabels(["Previous"])
                            
                            Spacer()
                            
                            //NEXT EXERCISE BUTTON
                            Button {
								guard var playlistIndex else { return }
								playlistIndex += 1
								if playlistIndex == playlist.count {
									playlistIndex = 0
								}
								self.playlistIndex = playlistIndex
								loadPlaylistItem(playlistIndex)
                            } label: {
                                ButtonView(buttonRoles: .nextItem, deviceType: deviceType)
                                    .opacity(0.75)
                            }
                            .accessibilityLabel("Go to next item in set list")
							.accessibilityInputLabels(["Next"])

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                    .padding(.bottom, 5)
                }
                
                //Normal Button Row
                ZStack {
                    Color.black.opacity(differentiateWithoutColor ? 0.0 : 0.25)
                    HStack {
                        Spacer()
                        
                        //START - PAUSE BUTTON
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
								managers.isTimerPaused = true
                            }
                            
                            //un-pause the timer
                            else {
								if audio {
									if managers.stretchPhase == .stretch {
										if timeRemaining == totalStretch {
											SoundManager.instance.playPrompt(sound: .countdownExpanded)
											DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
												withAnimation(.linear(duration: 0.25)) {
													managers.isTimerActive = true
													managers.isTimerPaused = false
												}
											}
										} else {
											SoundManager.instance.playPrompt(sound: .countdown)
											DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
												withAnimation(.linear(duration: 0.25)) {
													managers.isTimerActive = true
													managers.isTimerPaused = false
												}
											}
										}
									} else {
										withAnimation(.linear(duration: 0.25)) {
											managers.isTimerActive = true
											managers.isTimerPaused = false
										}
									}
								} else {
									withAnimation(.linear(duration: 0.25)) {
										managers.isTimerActive = true
										managers.isTimerPaused = false
									}
								}
							}
                        } label: {
<<<<<<< HEAD
							if #available(iOS 26, *) {
								ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
									.glassEffect()
							} else {
								ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
							}                        }
                        .accessibilityLabel(!managers.isTimerActive ? "Start Timer" : "Pause Timer")
						.accessibilityHint("This button starts or pauses the timer.")
						.accessibilityInputLabels(["Start", "Pause"])
=======
                            if #available(iOS 26.0, *) {
                                ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
                            } else {
                                ButtonView(buttonRoles: !managers.isTimerActive ? .play : .pause, deviceType: deviceType)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(!managers.isTimerActive ? "Start Timer" : "Pause Timer")
						.accessibilityInputLabels(["Start", "Start Timer", "Pause", "Pause Timer"])
>>>>>>> c35eb462b881b88c8861c9e560c4c61aaf30eb8f
                        
                        Spacer()
                        
                        //RESET BUTTON
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                managers.isTimerActive = false
                                managers.isTimerPaused = false
								managers.stretchPhase = .stop
                            }
                            repsCompleted = 0
                            timeRemaining = totalStretch
                        } label: {
							if #available(iOS 26, *) {
								ButtonView(buttonRoles: .reset, deviceType: .phone)
									.glassEffect()
							} else {
								ButtonView(buttonRoles: .reset, deviceType: .phone)
							}
                        }
						.buttonStyle(.plain)
                        .accessibilityLabel("Reset Timer")
						.accessibilityHint("This button reset the timer.")
						.accessibilityInputLabels(["Reset"])
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
                .padding(.bottom, 5)
                
            }
			
			//when user changes totalStretch in SettingsView, or app launches and loads totalStretch from AppStorage, force timeRemaining to reset to TotalStretch
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
            
            .onChange(of: isPlaylistActive) {
                guard var playlistIndex else { return }
                if isPlaylistActive {
                    playlistIndex = 0
                    loadPlaylistItem(playlistIndex)
                } else {
                    playlistItem = nil
                }
            }
            
			.onAppear {
				if !playlist.isEmpty {
					if isPlaylistActive {
						guard let playlistIndex else { return }
						loadPlaylistItem(playlistIndex)
					} else {
						playlistItem = nil
					}
				} else {
					playlistItem = nil
					isPlaylistActive = false
				}
			}
			
            .onDisappear {
                withAnimation(.linear(duration: 0.25)) {
                    managers.stretchPhase = .stop
                    updateEndAngle()
                }
                managers.isTimerActive = false
                managers.isTimerPaused = false
                timeRemaining = totalStretch
				repsCompleted = 0
            }
        }
    }
    
    //load playlistItem values into timer properties
    func loadPlaylistItem(_ index: Int) {
        guard !playlist.isEmpty else { return }
        playlistItem = playlist[index]
        if let playlistItem {
            totalStretch = playlistItem.stretchDuration ?? 10
            totalRest = playlistItem.restDuration ?? 5
            totalReps = playlistItem.repsToComplete ?? 3
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

    //function to stop timer
    func timerFullStop() {
        if audio {
            SoundManager.instance.playPrompt(sound: .relax)
        }
        withAnimation(.easeOut(duration: 0.5)) {
            managers.stretchPhase = .stop
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
<<<<<<< HEAD
					withAnimation(.easeOut(duration: 1)) {
                        timeRemaining = totalStretch
=======
					timeRemaining = totalStretch
					withAnimation(.easeOut(duration: 1)) {
>>>>>>> c35eb462b881b88c8861c9e560c4c61aaf30eb8f
                        managers.stretchPhase = .stretch
						updateEndAngle()
					}
				} else {
					guard var playlistIndex else { return }
					if repsCompleted != totalReps {
						withAnimation(.easeOut(duration: 1)) {
                            timeRemaining = totalStretch
                            managers.stretchPhase = .stretch
							updateEndAngle()
						}
						managers.isTimerActive = true
					} else {
                        //reps completed == total reps, goes to next stretch
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            playlistIndex += 1
                            self.playlistIndex = playlistIndex
                            loadPlaylistItem(playlistIndex)
                            timeRemaining = totalStretch
                            repsCompleted = 0
                            withAnimation {
                                managers.stretchPhase = .stretch
                            }
                            managers.isTimerActive = true
                        }
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
                    if repsCompleted != totalReps {
                        timeRemaining = totalStretch
                        withAnimation {
                            managers.stretchPhase = .stretch
                        }
                        if audio {
                            SoundManager.instance.playPrompt(sound: .stretch)
                        }
                    } else {
                        //reps completed == total reps, goes to next stretch
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            playlistIndex += 1
                            self.playlistIndex = playlistIndex
                            loadPlaylistItem(playlistIndex)
                            timeRemaining = totalStretch
                            repsCompleted = 0
                            withAnimation {
                                managers.stretchPhase = .stretch
                            }
                            managers.isTimerActive = true
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
}

#Preview {
    @Previewable @State var playlistIndex: Int? = 0
	@Previewable @State var playlistItem: PlaylistItem? = .sampleData[0]
	TimerDisplayView(playlistIndex: $playlistIndex, playlistItem: $playlistItem)
        .environment(Managers())
        .modelContainer(previewContainer)
}
