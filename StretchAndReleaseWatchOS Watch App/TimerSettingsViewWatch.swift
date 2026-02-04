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
    @Binding var promptVolume: Double
    
    // Local variables
    @State private var stretch: Float = 0
    @State private var rest: Float = 0
    @State private var reps: Float = 0
    @State private var page = 1
    @State private var isEditing = false
    
    // variable for button view
    var buttonRoles: ButtonRoles = .save
    var deviceType: DeviceType = .watch
    
    var body: some View {
        ScrollView(.vertical) {
            WatchAppSettingsView(stretch: $stretch, rest: $rest, reps: $reps)
                .padding(.vertical)
            Divider()
            WatchDeviceSettingsView(audio: $audio, haptics: $haptics, promptVolume: $promptVolume, isEditing: $isEditing)
                .padding(.vertical)
            Divider()
            Button {
                totalStretch = Int(stretch)
                totalRest = Int(rest)
                totalReps = Int(reps)
                SoundManager.instance.volume = promptVolume
                didSettingsChange = true
                dismiss()
            } label: {
                Text("SAVE")
                    .frame(width: 65, height: 25)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .background(.green)
                    .clipShape(.capsule)
                    .padding(.bottom, 5)
            }
            .padding(.vertical)
            .accessibilityHint("Save your settings and return to the main screen")
            .buttonStyle(.plain)
            
        }
        .onAppear {
            stretch = Float(totalStretch)
            rest = Float(totalRest)
            reps = Float(totalReps)
        }
    }
}

struct WatchAppSettingsView: View {
    
    @Binding var stretch: Float
    @Binding var rest: Float
    @Binding var reps: Float
    
    var body: some View {
        HStack {
            Text("Stretch")
                .font(.caption2)
            
            Spacer()
            
            Picker("Stretch Duration", selection: $stretch) {
                ForEach(1...30, id:\.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 50, height: 25)
            .focusable()
            .digitalCrownRotation($stretch)
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
        
        HStack {
            Text("Rest")
                .font(.caption2)
            
            Spacer()
            
            Picker("Rest Duration", selection: $rest) {
                ForEach(1...30, id:\.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 50, height: 25)
            .focusable()
            .digitalCrownRotation($rest)
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
            
            Spacer()
            
            Picker("Number of Repetitions", selection: $reps) {
                ForEach(1...30, id:\.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 50, height: 25)
            .focusable()
            .digitalCrownRotation($reps)
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
    }
}

struct WatchDeviceSettingsView: View {
    @Binding var audio: Bool
    @Binding var haptics: Bool
    @Binding var promptVolume: Double
    @Binding var isEditing: Bool
    
    var body: some View {
        Group {
            Toggle("Audio: \(audio ? "on" : "off")", isOn: $audio)
                .font(.caption2)
                .accessibilityHint("Turn audio cues on or off")
                .padding(.bottom, 5)
                .focusable(false)
            Toggle("Haptics: \(haptics ? "on" : "off")", isOn: $haptics)
                .font(.caption2)
                .accessibilityHint("Turn haptic feedback on or off")
                .padding(.bottom, 5)
                .focusable(false)
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
                .focusable()
                .digitalCrownRotation($promptVolume)
            }
        }
        .padding(.horizontal)
    }
}

struct SaveButtonView: View {
    
    var body: some View {
        
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
    
    TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps, didSettingsChange: $didSettingsChange, audio: $audio, haptics: $haptics, promptVolume: $promptVolume)
}
