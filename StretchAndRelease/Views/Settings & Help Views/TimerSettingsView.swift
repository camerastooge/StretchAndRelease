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
	@State private var isShowingEmptyPlaylistAlert = false
    @State private var showAddExerciseView = false
    
    @ScaledMetric var buttonWidth = 100
    
    private var volumeSlider: some View {
        Slider(
            value: $promptVolume,
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
        .accessibilityLabel("Volume")
        .accessibilityHint("Adjust volume of voice prompts")
        .accessibilityValue(String(promptVolume.formatted(.percent)))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: promptVolume += 0.1
            case .decrement: promptVolume -= 0.1
            @unknown default: print("not handled")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if !dynamicTypeSize.isAccessibilitySize {
                        PhoneTimerSettingsTypicalView(stretch: $stretch, rest: $rest, reps: $reps, isEditing: $isEditing)
                            .scrollDisabled(true)
                            .containerRelativeFrame(.vertical) { height, _ in
                                height * 0.55
                            }
                    } else {
                        PhoneTimerSettingsAccessibleView(stretch: $stretch, rest: $rest, reps: $reps, isEditing: $isEditing)
                            .scrollDisabled(false)
                            .containerRelativeFrame(.vertical) { height, _ in
                                height * 0.55
                            }
                    }
                }
                            
                VStack(spacing: 25) {
                    HStack {
                        Toggle("Use playlist", isOn: $isPlaylistActive)
                            .accessibilityHint("Turn playlist on or off")
                    }
                    HStack {
                        Toggle("Haptic feedback", isOn: $haptics)
                            .accessibilityHint("Turn haptic feedback on or off")
                    }
                    HStack {
                        Toggle("Audio cues", isOn: $audio)
                            .accessibilityHint("Turn audio cues on or off")
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
            .navigationDestination(isPresented: $showAddExerciseView) {
                AddExerciseView()
                    .navigationBarBackButtonHidden()
            }
            .alert("Empty Setlists", isPresented: $isShowingEmptyPlaylistAlert) {
                Button("Add Exercise") {
                    showAddExerciseView = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("There is nothing in the set list. \n Please add some exercises.")
            }
        }
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					totalStretch = stretch
					totalRest = rest
					totalReps = reps
					SoundManager.instance.volume = promptVolume
					managers.didSettingsChange = true
					dismiss()
				} label: {
					if #available(iOS 26.0, *) {
						Image(systemName: "chevron.left")
							.glassEffect(.clear)
					} else {
						Image(systemName: "chevron.left")
							.accessibilityLabel("Save changes and return to set list view")
					}
				}
				.buttonStyle(.plain)
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					dismiss()
				} label: {
					if #available(iOS 26.0, *) {
						Image(systemName: "x.circle")
							.glassEffect(.clear)
							.foregroundStyle(.red)
							.accessibilityLabel("Cancel and return to set list view")
					} else {
						Image(systemName: "x.circle.fill")
							.foregroundStyle(Color.red)
							.accessibilityLabel("Cancel and return to set list view")
					}
				}
				.buttonStyle(.plain)
			}
		}
        
        .onAppear {
            stretch = totalStretch
            rest = totalRest
            reps = totalReps
        }
        
        .onChange(of: isPlaylistActive) {
			print("is playlist active PRE: \(isPlaylistActive)")
			print("is playlist empty PRE: \(playlist.isEmpty)")
			if isPlaylistActive && playlist.isEmpty {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					isShowingEmptyPlaylistAlert = true
				}
				isPlaylistActive = false
            }
        }
    }
}





#Preview {
    SettingsView()
        .environment(Managers())
//        .modelContainer(previewContainer)
}
