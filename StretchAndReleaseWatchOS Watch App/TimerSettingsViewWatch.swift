//
//  TimerSettingsViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI

struct TimerSettingsViewWatch: View {
	//Environment properties
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
	@Environment(\.scenePhase) var scenePhase
	@Environment(Managers.self) var managers
	
	// Properties stored in UserDefaults
	@AppStorage("stretch") private var totalStretch = 10
	@AppStorage("rest") private var totalRest = 5
	@AppStorage("reps") private var totalReps = 3
	
	@AppStorage("audio") private var audio = true
	@AppStorage("haptics") private var haptics = true
	@AppStorage("promptVolume") private var promptVolume = 1.0
	@AppStorage("playlist") private var isPlaylistActive = true
    
    // Binding settings passed from Timer Main view
	@Binding var didSettingsChange: Bool
	
    // Local variables
    @State private var stretch = 0
    @State private var rest = 0
    @State private var reps = 0
	@State private var isHapticsOn = true
    @State private var isEditing = false
	@State private var isDismissalRequested = false
    
    // variable for button view
    var buttonRoles: ButtonRoles = .save
    var deviceType: DeviceType = .watch
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .center) {
                Color.clear
                
                VStack {
					TabView {
                        WatchAppSettingsView(stretch: $stretch, rest: $rest, reps: $reps)
                            .tag(0)
                        
						WatchDeviceSettingsView(audio: $audio, haptics: $isHapticsOn, promptVolume: $promptVolume, isPlaylistActive: $isPlaylistActive, isEditing: $isEditing)
                            .tag(1)
                    }
					.tabViewStyle(.page)
                }
				.navigationTitle("SETTINGS")
				.navigationBarTitleDisplayMode(.inline)
				
                .onAppear {
					stretch = totalStretch
					rest = totalRest
					reps = totalReps
                }
				
				.onDisappear {
					totalStretch = Int(stretch)
					totalRest = Int(rest)
					totalReps = Int(reps)
					SoundManager.instance.volume = promptVolume
					haptics = isHapticsOn
					didSettingsChange = true
				}
            }
        }
    }
}

struct WatchAppSettingsView: View {
    
    @Binding var stretch: Int
    @Binding var rest: Int
    @Binding var reps: Int
    
    var body: some View {
        List {
            NavigationLink(destination: VStack {
                Text("Stretch Duration")
                    .font(.headline)
                    .accessibilityLabel("Stretch")
                Picker("Stretch Duration", selection: $stretch) {
                    ForEach(1...60, id:\.self) {
                        Text("\($0) sec")
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Stretch duration \(stretch) seconds")
                .accessibilityHint("Adjust how long you want to hold each strecth")
                .accessibilityValue(String(stretch))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: stretch += 1
                    case .decrement: stretch -= 1
                    @unknown default: print("not handled")
                    }
                }
            }
            ) {
                HStack {
                    Text("Stretch")
                        .font(.caption2)
                    Spacer()
                    Text("\(stretch) sec")
                        .foregroundColor(.white)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Change the length of the time you hold each stretch")
            }
            
            NavigationLink(destination: VStack {
                Text("Rest Duration")
                    .font(.headline)
                    .accessibilityLabel("Rest")
                Picker("Rest Duration", selection: $rest) {
                    ForEach(1...30, id:\.self) {
                        Text("\($0) sec")
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Rest period \(rest) seconds")
                .accessibilityHint("Adjust rest period between stretches")
                .accessibilityValue(String(rest))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: rest += 1
                    case .decrement: rest -= 1
                    @unknown default: print("not handled")
                    }
                }
            }
            ) {
                HStack {
                    Text("Rest")
                        .font(.caption2)
                    Spacer()
                    Text("\(rest) sec")
                        .foregroundColor(.white)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Change the length of the rest period between stretches")
            }
            
            NavigationLink(destination: VStack {
                Text("Repetitions")
                    .font(.headline)
                    .accessibilityLabel("Repetitions")
                Picker("Number of Repetitions to Complete", selection: $reps) {
                    ForEach(1...20, id:\.self) {
                        Text("\($0) repetitions")
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Repetition count \(reps)")
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
            ) {
                HStack {
                    Text("Repetitions")
                        .font(.caption2)
                    Spacer()
                    Text("\(reps) reps")
                        .foregroundColor(.white)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Change the number of repetitions to perform")
            }
        }
    }
}

struct WatchDeviceSettingsView: View {
    @Binding var audio: Bool
    @Binding var haptics: Bool
    @Binding var promptVolume: Double
	@Binding var isPlaylistActive: Bool
	
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack {
			Toggle("Set list: \(haptics ? "on" : "off")", isOn: $isPlaylistActive)
				.padding(.top, 10)
            Toggle("Audio: \(audio ? "on" : "off")", isOn: $audio)
                .accessibilityHint("Turn audio cues on or off")
            Toggle("Haptics: \(haptics ? "on" : "off")", isOn: $haptics)
                .accessibilityHint("Turn haptic feedback on or off")
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
                .accessibilityLabel("Volume")
                .accessibilityHint("Adjust volume of voice prompts")
                .accessibilityValue(String(promptVolume.formatted(.percent)))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: promptVolume += 0.1
                    case .decrement: promptVolume -= 0.1
                    @unknown default: print("not handled")
                    }
                }
            }
        }
        .padding([.horizontal, .vertical])
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
	@Previewable @State var selectedTab = 1
	@Previewable @State var isPlaylistActive = false
	
    
	TimerSettingsViewWatch(didSettingsChange: $didSettingsChange)
        .environment(Managers())
}
