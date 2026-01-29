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
    @State private var stretch = 0
    @State private var rest = 0
    @State private var reps = 0
    @State private var isEditing = false
    @State private var page = 0
    
    // variable for button view
    var buttonRoles: ButtonRoles = .save
    var deviceType: DeviceType = .watch
    
    var body: some View {
        TabView(selection: $page) {
            Tab("Timer Settings", systemImage: "timer", value: 0) {
                WatchAppSettingsView(stretch: $stretch, rest: $rest, reps: $reps)
            }
            
            Tab("Device Settings", systemImage: "gear.fill", value: 1) {
                WatchDeviceSettingsView(audio: $audio, haptics: $haptics, promptVolume: $promptVolume, isEditing: $isEditing)
            }
        }
        .tabViewStyle(.verticalPage)
    }
//        GeometryReader { proxy in
//            let firstColumnWidth = proxy.size.width * (2/5)
//            let secondColumnWidth = proxy.size.width * (1.5/5)
            
//            ScrollView {
//                HStack {
//                    Text("Stretch")
//                        .font(.caption2)
//                        .frame(width: firstColumnWidth)
//                    
//                    Spacer()
//                    
//                    Picker("Stretch Duration", selection: $stretch) {
//                        ForEach(1...30, id:\.self) {
//                            Text("\($0)")
//                        }
//                    }
//                    .pickerStyle(.wheel)
//                    .labelsHidden()
//                    .frame(width: 50, height: 25)
//                    .frame(width: secondColumnWidth)
//                }
//                .accessibilityElement(children: .combine)
//                .accessibilityHint("Adjust how long you want to hold each stretch")
//                .accessibilityValue(String(stretch))
//                .accessibilityAdjustableAction { direction in
//                    switch direction {
//                    case .increment: stretch += 1
//                    case .decrement: stretch -= 1
//                    @unknown default:
//                        print("not handled")
//                    }
//                 }
//                .padding(.horizontal)
//                .padding(.top, 10)
//                
//                HStack {
//                    Text("Rest")
//                        .font(.caption2)
//                        .frame(width: firstColumnWidth)
//                    
//                    Spacer()
//                    
//                    Picker("Rest Duration", selection: $rest) {
//                        ForEach(1...30, id:\.self) {
//                            Text("\($0)")
//                        }
//                    }
//                    .pickerStyle(.wheel)
//                    .labelsHidden()
//                    .frame(width: 50, height: 25)
//                    .frame(width: secondColumnWidth)
//                }
//                .accessibilityElement(children: .combine)
//                .accessibilityHint("Adjust how long you want to rest between stretches")
//                .accessibilityValue(String(rest))
//                .accessibilityAdjustableAction { direction in
//                    switch direction {
//                    case .increment: rest += 1
//                    case .decrement: rest -= 1
//                    default: print("not handled")
//                    }
//                 }
//                .padding(.horizontal)
//                
//                HStack {
//                    Text("Reps")
//                        .font(.caption2)
//                        .frame(width: firstColumnWidth)
//                    
//                    Spacer()
//                    
//                    Picker("Number of Repetitions", selection: $reps) {
//                        ForEach(1...30, id:\.self) {
//                            Text("\($0)")
//                        }
//                    }
//                    .pickerStyle(.wheel)
//                    .labelsHidden()
//                    .frame(width: 50, height: 25)
//                    .frame(width: secondColumnWidth)
//                }
//                .accessibilityElement(children: .combine)
//                .accessibilityHint("Set the number of times you want to perform this stretch")
//                .accessibilityValue(String(reps))
//                .accessibilityAdjustableAction { direction in
//                    switch direction {
//                    case .increment: reps += 1
//                    case .decrement: reps -= 1
//                    default: print("not handled")
//                    }
//                 }
//                .padding(.horizontal)
                
//                Group {
//                    Toggle("Audio: \(audio ? "on" : "off")", isOn: $audio)
//                        .font(.caption2)
//                        .accessibilityHint("Turn audio cues on or off")
//                        .padding(.bottom, 5)
//                    Toggle("Haptics: \(haptics ? "on" : "off")", isOn: $haptics)
//                        .font(.caption2)
//                        .accessibilityHint("Turn haptic feedback on or off")
//                        .padding(.bottom, 5)
//                    HStack {
//                        Slider(
//                            value: $promptVolume,
//                            in: 0.0...1.0
//                        ) {
//                            Text("Prompt Volume")
//                        } minimumValueLabel: {
//                            Image(systemName: "speaker.slash.fill")
//                        } maximumValueLabel: {
//                            Image(systemName: "speaker.fill")
//                        } onEditingChanged: { editing in
//                            isEditing = editing
//                        }
//                    }
//                }
//                .frame(width: .infinity, height: 20)
//                .padding(.horizontal)
                
                // This is the save button
//                HStack(alignment: .center) {
//                    Spacer()
//                    
//                    Button {
//                        totalStretch = stretch
//                        totalRest = rest
//                        totalReps = reps
//                        SoundManager.instance.volume = promptVolume
//                        didSettingsChange = true
//                        dismiss()
//                    } label: {
//                        ButtonView(buttonRoles: buttonRoles, deviceType: deviceType)
//                    }
//                    .accessibilityHint("Save your settings and return to the main screen")
//                    .buttonStyle(.plain)
//                    
//                    Spacer()
//                }
            }
//            .frame(width: proxy.size.width, height: proxy.size.height)
//            .padding(.horizontal)
//            .onAppear {
//                stretch = totalStretch
//                rest = totalRest
//                reps = totalReps
//            }
//        }
//
//    }
//}

struct WatchAppSettingsView: View {
    
    @Binding var stretch: Int
    @Binding var rest: Int
    @Binding var reps: Int
    
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
            Toggle("Haptics: \(haptics ? "on" : "off")", isOn: $haptics)
                .font(.caption2)
                .accessibilityHint("Turn haptic feedback on or off")
                .padding(.bottom, 5)
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
        .frame(width: .infinity, height: 20)
        .padding(.horizontal)
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
