//
//  TimerSettingsViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI

struct TimerSettingsViewWatch: View {
    // Environment variables
    @Environment(\.dismiss) var dismiss
    
    // Binding settings passed from Timer Main view
    @Binding var totalStretch: Int
    @Binding var totalRest: Int
    @Binding var totalReps: Int
    
    @Binding var didSettingsChange: Bool
    @Binding var audio: Bool
    @Binding var haptics: Bool
    
    // Local variables
    @State private var stretch = 0
    @State private var rest = 0
    @State private var reps = 0
    
    var body: some View {
        GeometryReader { proxy in
            let firstColumnWidth = proxy.size.width * (2/5)
            let secondColumnWidth = proxy.size.width * (1.5/5)
            
            NavigationStack {
                HStack {
                    Text("Stretch")
                        .font(.caption2)
                        .frame(width: firstColumnWidth)
                    
                    Spacer()
                    
                    Picker("Stretch Duration", selection: $stretch) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 25)
                    .frame(width: secondColumnWidth)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Adjust how long you want to hold each stretch")
                .accessibilityValue(String(stretch))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: stretch += 1
                    case .decrement: stretch -= 1
                    @unknown default:
                        print("not handled")
                    }
                 }
                .padding(.horizontal)
                .padding(.top, 10)
                
                HStack {
                    Text("Rest")
                        .font(.caption2)
                        .frame(width: firstColumnWidth)
                    
                    Spacer()
                    
                    Picker("Rest Duration", selection: $rest) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 25)
                    .frame(width: secondColumnWidth)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Adjust how long you want to rest between stretches")
                .accessibilityValue(String(rest))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: rest += 1
                    case .decrement: rest -= 1
                    default: print("not handled")
                    }
                 }
                .padding(.horizontal)
                
                HStack {
                    Text("Reps")
                        .font(.caption2)
                        .frame(width: firstColumnWidth)
                    
                    Spacer()
                    
                    Picker("Number of Repetitions", selection: $reps) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 25)
                    .frame(width: secondColumnWidth)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Set the number of times you want to perform this stretch")
                .accessibilityValue(String(reps))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: reps += 1
                    case .decrement: reps -= 1
                    default: print("not handled")
                    }
                 }
                .padding(.horizontal)
                
                Group {
                    Toggle("Audio: \(audio ? "on" : "off")", isOn: $audio)
                        .font(.caption2)
                        .accessibilityHint("Turn audio cues on or off")
                    Toggle("Haptics: \(haptics ? "on" : "off")", isOn: $haptics)
                        .font(.caption2)
                        .accessibilityHint("Turn haptic feedback on or off")
                }
                .frame(width: .infinity, height: 20)
                .padding(.horizontal)
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Button {
                        totalStretch = stretch
                        totalRest = rest
                        totalReps = reps
                        didSettingsChange = true
                        dismiss()
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                            .font(.title)
                            .frame(width: 30, height: 30)
                            .background(Color.green)
                            .clipShape(Circle())
                            .frame(alignment: .bottom)
                    }
                    .accessibilityHint("Save your settings and return to the main screen")
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .padding(.horizontal)
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
    
    TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange, audio: $audio, haptics: $haptics)
}
