//
//  AddExerciseToPlaylistView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/26/26.
//

import SwiftUI
import SwiftData

struct EditExerciseView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State var name = ""
    @State var stretch = 10
    @State var rest = 5
    @State var reps = 3
    
    @Bindable var playlistItem: PlaylistItem
    
    @ScaledMetric var buttonWidth = 100
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color.clear.gradientBackground()
                    
                    VStack {
                        Form {
                            Section("Stretch name") {
                                TextField("\(name)", text: $name)
                            }
                            .padding(.bottom)
                            
                            Section("Stretch duration") {
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
                            }
                            .padding(.bottom)
                            
                            Section("Rest duration") {
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
                            }
                            .padding(.bottom)

                            
                            Section("Number of repetitions") {
                                HStack {
                                    Picker("Number of Repetitions to Complete", selection: $reps) {
                                        ForEach(1...20, id:\.self) {
                                            Text("\($0)").font(.headline)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    Text("reps")
                                        .font(.headline)
                                }
                                .font(.subheadline)
                                .frame(height: 40)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("Repetition count \(reps)")
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
                        }
                        .scrollContentBackground(.hidden)
                        
                        Spacer()
                        
                        Button {
                            playlistItem.name = name
                            playlistItem.stretchDuration = stretch
                            playlistItem.restDuration = rest
                            playlistItem.repsToComplete = reps
                            do {
                                try modelContext.save()
                            } catch {
                                print("Error: \(error.localizedDescription)")
                            }
                            dismiss()
                        } label: {
                            if #available(iOS 26.0, *) {
                                Text("SAVE")
                                    .frame(width: buttonWidth, height: 50)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .background(.green)
                                    .clipShape(.capsule)
                                    .glassEffect()
                                    .padding(.top, 25)
                                    .padding(.bottom, 25)
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                            } else {
                                Text("SAVE")
                                    .frame(width: buttonWidth, height: 50)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .background(.green)
                                    .clipShape(.capsule)
                                    .padding(.top, 25)
                                    .padding(.bottom, 25)
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                            }
                        }
                    }
                }
                .navigationTitle("Edit Exercise")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            name = playlistItem.name ?? "Exercise"
            stretch = playlistItem.stretchDuration ?? 10
            rest = playlistItem.restDuration ?? 5
            reps = playlistItem.repsToComplete ?? 3
        }
    }
}

#Preview {
    @Previewable @State var item = PlaylistItem.sampleData[0]
    
    EditExerciseView(playlistItem: item)
}
