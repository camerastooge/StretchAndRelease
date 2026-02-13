//
//  PhoneTimerSettingsAccessibleView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/13/26.
//
import SwiftUI

struct PhoneTimerSettingsAccessibleView: View {
    @Binding var stretch: Int
    @Binding var rest: Int
    @Binding var reps: Int
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    Section {
                        HStack {
                            Spacer()
                            Picker("Stretch", selection: $stretch) {
                                ForEach(1...60, id:\.self) {
                                    Text("\($0)")
                                        .font(.largeTitle)
                                }
                            }
                            .pickerStyle(.menu)
                            Spacer()
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Stretch duration \(stretch) seconds")
                    .accessibilityHint("Adjust how long you want to hold each stretch")
                    .accessibilityValue(String(stretch))
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: stretch += 1
                        case .decrement: stretch -= 1
                        @unknown default: print("not handled")
                        }
                    }
                    
                    Section {
                        HStack {
                            Spacer()
                            Picker("Rest", selection: $rest) {
                                ForEach(1...30, id:\.self) {
                                    Text("\($0)")
                                        .font(.largeTitle)
                                }
                            }
                            .pickerStyle(.menu)
                            Spacer()
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Rest duration \(rest) seconds")
                    .accessibilityHint("Adjust how long you want to rest between stretches")
                    .accessibilityValue(String(rest))
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: rest += 1
                        case .decrement: rest -= 1
                        @unknown default: print("not handled")
                        }
                    }
                    
                    Section {
                        HStack {
                            Spacer()
                            Picker("Reps", selection: $reps) {
                                ForEach(1...20, id:\.self) {
                                    Text("\($0)")
                                        .font(.largeTitle)
                                }
                            }
                            .pickerStyle(.menu)
                            Spacer()
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Repetition count \(stretch)")
                    .accessibilityHint("Adjust how many times to perform the stretch")
                    .accessibilityValue(String(reps))
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: reps += 1
                        case .decrement: reps -= 1
                        @unknown default: print("not handled")
                        }
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
    
    PhoneTimerSettingsAccessibleView(stretch: $stretch, rest: $rest, reps: $reps, isEditing: $isEditing)
}
