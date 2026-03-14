//
//  TimerSettingsView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

struct SettingsView: View {
    // Environment variables
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dismiss) var dismiss
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
    
    //local variables
    @State private var stretch = 0
    @State private var rest = 0
    @State private var reps = 0
    @State private var isEditing = false
    
    @ScaledMetric var buttonWidth = 100
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Section {
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
                
                            
                Section {
                    Section {
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
                        }
                    }
                    .padding(.horizontal)
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                }
                .padding(.bottom)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button(role: .cancel) {
                            dismiss()
                        } label: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "x.circle.fill")
                                    .glassEffect()
                                    .tint(.red)
                                    .accessibilityLabel("Return to main screen")
                                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            } else {
                                Image(systemName: "x.circle.fill")
                                    .tint(.red)
                                    .accessibilityLabel("Return to main screen")
                                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            }
                        }
                    }
                }
            }
            .scrollDisabled(true)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                totalStretch = stretch
                totalRest = rest
                totalReps = reps
                SoundManager.instance.volume = promptVolume
                managers.didStatusChange = true
                dismiss()
            } label: {
                Text("SAVE")
                    .frame(width: buttonWidth, height: 50)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .background(.green)
                    .clipShape(.capsule)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            }
            .accessibilityLabel("Save")
            .accessibilityHint("Save your settings and return to the main screen")
        }
        .onAppear {
            stretch = totalStretch
            rest = totalRest
            reps = totalReps
        }
    }
}





#Preview {
    SettingsView()
        .environment(Managers())
}
