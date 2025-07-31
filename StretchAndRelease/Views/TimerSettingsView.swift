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
    @Binding var totalStretch: Int
    @Binding var totalRest: Int
    @Binding var totalReps: Int
    @Binding var didSettingsChange: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Stretch")
                            .accessibilityLabel("Stretch Duration")
                        Picker("Stretch Duration", selection: $totalStretch) {
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
                .accessibilityValue(String(totalStretch))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: totalStretch += 1
                    case .decrement: totalStretch -= 1
                    @unknown default:
                        print("not handled")
                    }
                 }

                
                Section {
                    HStack {
                        Text("Rest")
                            .accessibilityLabel("Rest Duration")
                        Picker("Rest Duration", selection: $totalRest) {
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
                .accessibilityValue(String(totalRest))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: totalRest += 1
                    case .decrement: totalRest -= 1
                    default: print("not handled")
                    }
                 }
                .frame(height: 100)
                .padding(.horizontal)
                
                Section {
                    HStack {
                        Text("Repetitions")
                            .accessibilityLabel("Number of Repetitiions")
                        Picker("Number of Repetitions to Complete", selection: $totalReps) {
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
                .accessibilityValue(String(totalReps))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: totalReps += 1
                    case .decrement: totalReps -= 1
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
                    UserDefaults.standard.set(totalStretch, forKey: "totalStretch")
                    UserDefaults.standard.set(totalRest, forKey: "totalRest")
                    UserDefaults.standard.set(totalReps, forKey: "totalReps")
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
    @Previewable @State var totalStretch: Int = 0
    @Previewable @State var totalRest: Int = 0
    @Previewable @State var totalReps: Int = 0
    @Previewable @State var didSettingsChange: Bool = false
    SettingsView(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange)
}
