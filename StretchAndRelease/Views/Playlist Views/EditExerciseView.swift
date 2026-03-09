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
    
    @Bindable var playlistItem: PlaylistItem
    
//    @State private var name = ""
//    @State private var stretch = 10
//    @State private var rest = 5
//    @State private var reps = 5
    
    @ScaledMetric var buttonWidth = 100
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Stretch name") {
                        TextField("\(playlistItem.name)", text: $playlistItem.name)
                    }
                    .padding(.bottom)
                    
                    Section("Stretch duration") {
                        HStack {
                            Picker("Stretch", selection: $playlistItem.stretchDuration) {
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
                        .accessibilityLabel("Stretch duration \(playlistItem.stretchDuration) seconds")
                        .accessibilityHint("Adjust how long you want to hold each stretch")
                        .accessibilityValue(String(playlistItem.stretchDuration))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: playlistItem.stretchDuration += 1
                            case .decrement: playlistItem.stretchDuration -= 1
                            @unknown default: print("not handled")
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    Section("Rest duration") {
                        HStack {
                            Picker("Rest Duration", selection: $playlistItem.restDuration) {
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
                        .accessibilityLabel("Rest duration \(playlistItem.restDuration) seconds")
                        .accessibilityHint("Adjust how long you want to rest between stretches")
                        .accessibilityValue(String(playlistItem.restDuration))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: playlistItem.restDuration += 1
                            case .decrement: playlistItem.restDuration -= 1
                            @unknown default: print("not handled")
                            }
                        }
                    }
                    .padding(.bottom)

                    
                    Section("Number of repetitions") {
                        HStack {
                            Picker("Number of Repetitions to Complete", selection: $playlistItem.repsToComplete) {
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
                        .accessibilityLabel("Repetition count \(playlistItem.repsToComplete)")
                        .accessibilityHint("Set the number of times you want to perform this stretch")
                        .accessibilityValue(String(playlistItem.repsToComplete))
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: playlistItem.repsToComplete += 1
                            case .decrement: playlistItem.repsToComplete -= 1
                            default: print("not handled")
                            }
                        }

                    }
                }
                
                Spacer()
                
                Button {
//                    playlistItem.name = name
//                    playlistItem.stretchDuration = stretch
//                    playlistItem.restDuration = rest
//                    playlistItem.repsToComplete = reps
//                    modelContext.insert(playlistItem)
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
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
        }
//        .onAppear {
//            name = playlistItem.name
//            stretch  = playlistItem.stretchDuration
//            rest = playlistItem.restDuration
//            reps = playlistItem.repsToComplete
//        }
    }
}

#Preview {
    @Previewable @State var item = PlaylistItem.sampleData[0]
    
    EditExerciseView(playlistItem: item)
}
