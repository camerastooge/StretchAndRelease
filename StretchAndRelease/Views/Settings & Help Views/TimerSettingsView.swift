//
//  TimerSettingsView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // Environment variables
    @Environment(\.colorScheme) var colorScheme
	@Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(Managers.self) var managers
    
    // Properties stored in UserDefaults
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    @AppStorage("promptVolume") private var promptVolume = 1.0
    @AppStorage("playlist") private var isPlaylistActive = false
    
    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    //local variables
    @State private var stretch = 0
    @State private var rest = 0
    @State private var reps = 0
    @State private var isEditing = false
    @State private var playlistToggle = false
    @State private var hapticToggle = false
    @State private var audioToggle = false
    @State private var volumeValue = 0.0
    
	@State private var isShowingEmptyPlaylistAlert = false
    @State private var showAddExerciseView = false
    
    @ScaledMetric var buttonWidth = 100
    
    private var volumeSlider: some View {
        Slider(
            value: $volumeValue,
            in: 0.0...1.0
        ) {
            Text("Prompt Volume")
        } minimumValueLabel: {
            Image(systemName: "speaker.slash.fill")
        } maximumValueLabel: {
            Image(systemName: "speaker.wave.3")
        } onEditingChanged: { editing in
            isEditing = editing
        }
        .accessibilityLabel("Volume: String(volumeValue.formatted(.percent)) percent")
        .accessibilityHint("Adjust volume of voice prompts")
        .accessibilityValue(String(volumeValue.formatted(.percent)))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: volumeValue += 0.1
            case .decrement: volumeValue -= 0.1
            @unknown default: print("not handled")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if !dynamicTypeSize.isAccessibilitySize {
                        PhoneTimerSettingsTypicalView(stretch: $stretch, rest: $rest, reps: $reps)
                            .scrollDisabled(true)
                            .containerRelativeFrame(.vertical) { height, _ in
                                height * 0.55
                            }
                    } else {
                        PhoneTimerSettingsAccessibleView(stretch: $stretch, rest: $rest, reps: $reps)
                            .scrollDisabled(false)
                            .containerRelativeFrame(.vertical) { height, _ in
                                height * 0.55
                            }
                    }
                }
                            
                VStack(spacing: 25) {
                    HStack {
                        Toggle("Use playlist", isOn: $playlistToggle)
							.accessibilityLabel(playlistToggle ? "set list is active" : "set list is not active")
                            .accessibilityHint("Turn set list on or off")
							.accessibilityInputLabels(["set list"])
                    }
                    HStack {
                        Toggle("Haptic feedback", isOn: $hapticToggle)
							.accessibilityLabel(hapticToggle ? "haptic feedback is enabled" : "haptic feedback is disabled")
                            .accessibilityHint("Turn haptic feedback on or off")
							.accessibilityInputLabels(["feedback", "haptics"])
                    }
                    HStack {
                        Toggle("Audio cues", isOn: $audioToggle)
							.accessibilityLabel(audio ? "audio cues are enabled" : "audio cues are disabled")
                            .accessibilityHint("Turn audio cues on or off")
							.accessibilityInputLabels(["audio", "prompts"])
                    }
                    HStack {
                        volumeSlider
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            }
            .scrollDisabled(true)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
			.alert("Empty Setlists", isPresented: $isShowingEmptyPlaylistAlert) {
                Button("Add Stretch") {
                    showAddExerciseView = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("There is nothing in the set list. \n Please add some exercises.")
            }
        }
		.fullScreenCover(isPresented: $showAddExerciseView,
						 onDismiss: {
			if !playlist.isEmpty {
				playlistToggle = true
			}
		},
						 content: {
			NavigationStack {
				AddExerciseView()
					.navigationBarBackButtonHidden()
			}
		})
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					totalStretch = stretch
					totalRest = rest
					totalReps = reps
                    audio = audioToggle
                    haptics = hapticToggle
                    isPlaylistActive = playlistToggle
                    promptVolume = volumeValue
                    SoundManager.instance.volume = promptVolume
					managers.didSettingsChange = true
					dismiss()
				} label: {
					if #available(iOS 26.0, *) {
						Image(systemName: "chevron.left")
							.glassEffect(.clear)
					} else {
						Image(systemName: "chevron.left")
					}
				}
				.buttonStyle(.plain)
				.accessibilityElement(children: .ignore)
				.accessibilityLabel("Save changes")
				.accessibilityInputLabels(["save"])
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					dismiss()
				} label: {
					if #available(iOS 26.0, *) {
						Image(systemName: "x.circle")
							.glassEffect(.clear)
							.foregroundStyle(.red)
					} else {
						Image(systemName: "x.circle.fill")
							.foregroundStyle(Color.red)
					}
				}
				.buttonStyle(.plain)
				.accessibilityElement(children: .ignore)
				.accessibilityLabel("Discard changes")
				.accessibilityInputLabels(["cancel"])
			}
		}
        
        .onAppear {
            stretch = totalStretch
            rest = totalRest
            reps = totalReps
            playlistToggle = isPlaylistActive
            hapticToggle = haptics
            audioToggle = audio
            volumeValue = promptVolume
        }
        
        .onChange(of: playlistToggle, initial: false) {
			if playlistToggle && playlist.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					isShowingEmptyPlaylistAlert = true
                    playlistToggle = false
				}
            }
        }
    }
}





#Preview {
    SettingsView()
        .environment(Managers())
//        .modelContainer(previewContainer)
}
