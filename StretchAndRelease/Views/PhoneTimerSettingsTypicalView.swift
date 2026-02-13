//
//  PhoneTimerSettingsTypicalView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/13/26.
//
import SwiftUI

struct PhoneTimerSettingsTypicalView: View {
    @Binding var stretch: Int
    @Binding var rest: Int
    @Binding var reps: Int
    @Binding var isEditing: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section("Stretch Time") {
                    HStack {
                        Picker("Stretch", selection: $stretch) {
                            ForEach(1...60, id:\.self) {
                                Text("\($0)")
                                    .font(.headline)
                            }
                        }
                        .pickerStyle(.wheel)
                        Text("sec.")
                            .font(.headline)
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
                    HStack {
                        Picker("Rest Duration", selection: $rest) {
                            ForEach(1...30, id:\.self) {
                                Text("\($0)")
                                    .font(.headline)
                            }
                        }
                        .pickerStyle(.wheel)
                        Text("sec.")
                            .font(.headline)
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
                    HStack {
                        Picker("Number of Repetitions to Complete", selection: $reps) {
                            ForEach(1...20, id:\.self) {
                                Text("\($0)").font(.headline)
                            }
                        }
                        .pickerStyle(.wheel)
                        Text("reps")
                            .font(.headline)
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
    }
}


#Preview {
    @Previewable @State var stretch = 10
    @Previewable @State var rest = 5
    @Previewable @State var reps = 3
    @Previewable @State var isEditing = true
    
    PhoneTimerSettingsTypicalView(stretch: $stretch, rest: $rest, reps: $reps, isEditing: $isEditing)
}
