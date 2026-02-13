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
    
    // Binding settings passed from Timer Main view
    @Binding var totalStretch: Int
    @Binding var totalRest: Int
    @Binding var totalReps: Int
    
    @Binding var didSettingsChange: Bool
    @Binding var audio: Bool
    @Binding var haptics: Bool
    @Binding var promptVolume: Double
    
    //local variables
    @State private var stretch = 0
    @State private var rest = 0
    @State private var reps = 0
    @State private var isEditing = false
    
    @ScaledMetric var buttonWidth = 100
    
    var body: some View {
        Group {
            if !dynamicTypeSize.isAccessibilitySize {
                PhoneTimerSettingsTypicalView(stretch: $stretch, rest: $rest, reps: $reps, isEditing: $isEditing)
                    .scrollDisabled(true)
                    .containerRelativeFrame(.vertical) { height, _ in
                        height * 0.69
                    }
            } else {
                PhoneTimerSettingsAccessibleView(stretch: $stretch, rest: $rest, reps: $reps, isEditing: $isEditing)
                    .scrollDisabled(false)
                    .containerRelativeFrame(.vertical) { height, _ in
                        height * 0.69
                    }
            }
        }
        
        Group {
            Section {
                HStack {
                    Toggle("Haptic feedback: \(haptics ? "on" : "off")", isOn: $haptics)
                        .accessibilityHint("Turn haptic feedback on or off")
                }
                HStack {
                    Toggle("Audio cues: \(audio ? "on" : "off")", isOn: $audio)
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
                    .accessibilityHint("Adjust volume of voice prompts")
                    .accessibilityValue(String(promptVolume))
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: promptVolume += 0.1
                        case .decrement: promptVolume -= 0.1
                        @unknown default: print("not handled")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            
            
            Section {
                Button {
                    totalStretch = stretch
                    totalRest = rest
                    totalReps = reps
                    SoundManager.instance.volume = promptVolume
                    didSettingsChange = true
                    dismiss()
                } label: {
                    Text("SAVE")
                        .frame(width: buttonWidth, height: 50)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .background(.green)
                        .clipShape(.capsule)
                        .padding(.bottom, 5)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                }
                .accessibilityLabel("Save")
                .accessibilityHint("Save your settings and return to the main screen")
            }
        }
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
        .onAppear {
            stretch = totalStretch
            rest = totalRest
            reps = totalReps
        }
    }
}





#Preview {
    @Previewable @State var didSettingsChange: Bool = false
    @Previewable @State var totalStretch = 10
    @Previewable @State var totalRest = 5
    @Previewable @State var totalReps = 3
    @Previewable @State var audio = true
    @Previewable @State var haptics = true
    @Previewable @State var promptVolume = 1.0
    
    SettingsView(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange, audio: $audio, haptics: $haptics, promptVolume: $promptVolume)
}
