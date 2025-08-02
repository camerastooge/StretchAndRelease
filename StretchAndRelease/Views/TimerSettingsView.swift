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
    @Environment(\.dismiss) var dismiss
    
    // Binding settings passed from Timer Main view
    @EnvironmentObject var timerSettings: TimerSettings
    @Binding var didSettingsChange: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Stretch")
                            .accessibilityLabel("Stretch Duration")
                        Picker("Stretch Duration", selection: $timerSettings.totalStretch) {
                            ForEach(1...30, id:\.self) {
                                Text("\($0)")
                            }
                        }
                        .pickerStyle(.wheel)
                        Text("sec.")
                            .font(.caption)
                            .accessibilityLabel("seconds")
                    }
                    .frame(height: 100)
                    .padding(.horizontal)
                }
                .accessibilityHint("Adjust how long you want to hold each stretch")
                .accessibilityValue(String(timerSettings.totalStretch))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: timerSettings.totalStretch += 1
                    case .decrement: timerSettings.totalStretch -= 1
                    @unknown default:
                        print("not handled")
                    }
                 }

                
                Section {
                    HStack {
                        Text("Rest")
                            .accessibilityLabel("Rest Duration")
                        Picker("Rest Duration", selection: $timerSettings.totalRest) {
                            ForEach(1...10, id:\.self) {
                                Text("\($0)")
                            }
                        }
                        .pickerStyle(.wheel)
                        Text("sec.")
                            .font(.caption)
                            .accessibilityLabel("seconds")
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Adjust how long you want to rest between stretches")
                .accessibilityValue(String(timerSettings.totalRest))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: timerSettings.totalRest += 1
                    case .decrement: timerSettings.totalRest -= 1
                    default: print("not handled")
                    }
                 }
                .frame(height: 100)
                .padding(.horizontal)
                
                Section {
                    HStack {
                        Text("Repetitions")
                            .accessibilityLabel("Number of Repetitiions")
                        Picker("Number of Repetitions to Complete", selection: $timerSettings.totalReps) {
                            ForEach(1...10, id:\.self) {
                                Text("\($0)")
                            }
                        }
                        .pickerStyle(.wheel)
                        Text("reps")
                            .font(.caption)
                            .accessibilityLabel("repetitions")
                    }
                }
                .frame(height: 100)
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityHint("Set the number of times you want to perform this stretch")
                .accessibilityValue(String(timerSettings.totalReps))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: timerSettings.totalReps += 1
                    case .decrement: timerSettings.totalReps -= 1
                    default: print("not handled")
                    }
                 }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                    .accessibilityLabel("Return to main screen")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            VStack {
                Button {
                    didSettingsChange = true
                    dismiss()
                } label: {
                    Text("SAVE")
                        .frame(width: 100, height: 50)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .background(.green)
                        .clipShape(.capsule)
                        .shadow(color: colorScheme == .light ? .black.opacity(0.25) : .white.opacity(0.5), radius: 0.8, x: 2, y: 2)
                        .padding(.bottom, 5)
                }
                .accessibilityHint("Save your settings and return to the main screen")
            }
        }
    }
}

#Preview {
    @Previewable @State var didSettingsChange = false
    SettingsView(didSettingsChange: $didSettingsChange)
}
