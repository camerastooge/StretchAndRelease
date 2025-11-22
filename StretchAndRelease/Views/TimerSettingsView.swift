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
    
    var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
    }
    
    @ScaledMetric var buttonWidth = 100

    var body: some View {
        NavigationStack {
                VStack {
                    Form {
                        Section("Stretch Time") {
                            dynamicLayout {
                                Picker("Stretch Duration", selection: $stretch) {
                                    ForEach(1...30, id:\.self) {
                                        Text("\($0)")
                                            .font(.title2)
                                    }
                                }
                                .pickerStyle(.wheel)
                                Text("sec.")
                                    .font(.title2)
                                    .accessibilityLabel("seconds")
                            }
                            .font(.headline)
                            .frame(height: 40)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Adjust how long you want to hold each strecth")
                        .accessibilityValue(String(stretch))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: stretch += 1
                            case .decrement: stretch -= 1
                            @unknown default: print("not handled")
                            }
                        }
                        
                        Section("Rest Time") {
                            dynamicLayout {
                                Picker("Rest Duration", selection: $rest) {
                                    ForEach(1...10, id:\.self) {
                                        Text("\($0)")
                                            .font(.title2)
                                    }
                                }
                                .pickerStyle(.wheel)
                                Text("sec.")
                                    .font(.title2)
                                    .accessibilityLabel("seconds")
                            }
                            .font(.subheadline)
                            .frame(height: 40)
                        }                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Adjust how long you want to rest between stretches")
                        .accessibilityValue(String(rest))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: rest += 1
                            case .decrement: rest -= 1
                            @unknown default: print("not handled")
                            }
                         }
                        
                        Section("Repetitions") {
                            dynamicLayout {
                                Picker("Number of Repetitions to Complete", selection: $reps) {
                                    ForEach(1...20, id:\.self) {
                                        Text("\($0)").font(.title2)
                                    }
                                }
                                .pickerStyle(.wheel)
                                Text("reps")
                                    .font(.title2)
                                    .accessibilityLabel("repetitions")
                            }
                            .font(.subheadline)
                            .frame(height: 40)
                        }                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Set the number of times you want to perform this stretch")
                        .accessibilityValue(String(reps))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: reps += 1
                            case .decrement: reps -= 1
                            default: print("not handled")
                            }
                         }
                    }
                    .padding(.horizontal)
                }
                .scrollDisabled(true)
                .containerRelativeFrame(.vertical) { height, _ in
                    height * 0.69
                }
                .toolbar {
                    ToolbarItem {
                        Button(role: .cancel) {
                            dismiss()
                        } label: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "x.circle.fill")
                                    .glassEffect()
                            } else {
                                Image(systemName: "x.circle.fill")
                            }
                        }
                        .tint(.red)
                        .accessibilityLabel("Return to main screen")
                    }
                }                    
                
                Group {
                    Section {
                        HStack {
                            Toggle("Audio cues: \(audio ? "on" : "off")", isOn: $audio)
                                .accessibilityHint("Turn audio cues on or off")
                        }
                        HStack {
                            Toggle("Haptic feedback: \(haptics ? "on" : "off")", isOn: $haptics)
                                .accessibilityHint("Turn haptic feedback on or off")
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
                                Image(systemName: "speaker.fill")
                            } onEditingChanged: { editing in
                                isEditing = editing
                            }
                        }
                    }
                        .padding(.horizontal)

                    
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
                        }
                        .accessibilityHint("Save your settings and return to the main screen")
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    stretch = totalStretch
                    rest = totalRest
                    reps = totalReps
                }
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
