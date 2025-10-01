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
    
    //local variables
    var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
    }
    
    @ScaledMetric var buttonWidth = 100

    var body: some View {
            NavigationStack {
                ScrollView {
                    Group {
                        Section("Stretch Time") {
                            dynamicLayout {
                                Picker("Stretch Duration", selection: $totalStretch) {
                                    ForEach(1...30, id:\.self) {
                                        Text("\($0)").font(.title2)
                                    }
                                }
                                .pickerStyle(.wheel)
                                Text("sec.")
                                    .font(.title2)
                                    .accessibilityLabel("seconds")
                            }
                            .font(.headline)
                            .frame(height: 45)
                        }
                        .padding(.vertical, 10)
                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Adjust how long you want to hold each stretch")
                        .accessibilityValue(String(totalStretch))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: totalStretch += 1
                            case .decrement: totalStretch -= 1
                            @unknown default:
                                print("not handled")
                            }
                         }
                        
                        Divider()
                            .frame(height: 5)
                            .background(.secondary).opacity(0.75)
                        
                        Section("Rest Time") {
                            dynamicLayout {
                                Picker("Rest Duration", selection: $totalRest) {
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
                            .frame(height: 45)
                        }
                        .padding(.vertical, 10)
                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Adjust how long you want to rest between stretches")
                        .accessibilityValue(String(totalRest))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: totalRest += 1
                            case .decrement: totalRest -= 1
                            @unknown default: print("not handled")
                            }
                         }
                        
                        Divider()
                            .frame(height: 5)
                            .background(.secondary).opacity(0.75)
                        
                        Section("Repetitions") {
                            dynamicLayout {
                                Picker("Number of Repetitions to Complete", selection: $totalReps) {
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
                            .frame(height: 45)
                        }
                        .padding(.vertical, 5)
                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Set the number of times you want to perform this stretch")
                        .accessibilityValue(String(totalReps))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: totalReps += 1
                            case .decrement: totalReps -= 1
                            default: print("not handled")
                            }
                         }
                    }
                    .padding(.horizontal)
                }
                .scrollDisabled(true)
                .containerRelativeFrame(.vertical) { height, _ in
                    height * 0.66
                }
                
                Divider()
                    .frame(height: 5)
                    .background(.secondary)
                    .padding(.horizontal, 15)
                    .toolbar {
                        ToolbarItem {
                            Button {
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
                    Section("Interface Settings") {
                        HStack {
                            Toggle("Audio cues on or off", isOn: $audio)
                                .accessibilityHint("Turn audio cues on or off")
                        }
                        HStack {
                            Toggle("Haptic feedback on or off", isOn: $haptics)
                                .accessibilityHint("Turn haptic feedback on or off")
                        }
                    }
                        .padding(.horizontal)

                    
                    Section {
                        Button {
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
    
    SettingsView(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange, audio: $audio, haptics: $haptics)
}
