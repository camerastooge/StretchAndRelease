//
//  TimerSettingsViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI
import SwiftData

struct TimerSettingsViewWatch: View {
	//Environment properties
	@Environment(\.dismiss) var dismiss
	@Environment(Managers.self) var managers
    
    // Properties stored in UserDefaults
    @AppStorage("stretch") private var totalStretch = 10
    @AppStorage("rest") private var totalRest = 5
    @AppStorage("reps") private var totalReps = 3
    
    @AppStorage("audio") private var audio = true
    @AppStorage("haptics") private var haptics = true
    @AppStorage("promptVolume") private var promptVolume = 1.0
    @AppStorage("playlist") private var isPlaylistActive = false
    
    //local variables
    @State private var stretch = 0
    @State private var rest = 0
    @State private var reps = 0
    @State private var isEditing = false
    @State private var playlistToggle = false
    @State private var hapticToggle = false
    @State private var audioToggle = false
    @State private var volumeValue = 0.5
    
    @State private var isShowingEmptyPlaylistAlert = false
    @State private var showAddExerciseView = false
	
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
                        
                        WatchDeviceSettingsView(playlistToggle: $playlistToggle, hapticToggle: $hapticToggle, audioToggle: $audioToggle, volumeValue: $volumeValue, showAddExerciseView: $showAddExerciseView)
                    }
					.tabViewStyle(.page)
                }
				.navigationTitle("SETTINGS")
				.navigationBarTitleDisplayMode(.inline)
				.navigationDestination(isPresented: $showAddExerciseView) {
					AddExerciseViewWatch()
						.navigationBarBackButtonHidden()
				}
            }
        }
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					totalStretch = stretch
                    totalRest = rest
                    totalReps = reps
                    audio = audioToggle
                    haptics = hapticToggle
                    isPlaylistActive = playlistToggle
                    promptVolume = volumeValue
                    SoundManager.instance.volume = promptVolume
                    managers.didSettingsChange = true
                    dismiss()
				} label: {
					if #available(watchOS 26.0, *) {
						Image(systemName: "chevron.left")
							.glassEffect(.clear)
					} else {
						Image(systemName: "chevron.left")
					}
				}
				.buttonStyle(.plain)
				.accessibilityLabel("Save changes and return to set list view")
				.accessibilityInputLabels(["Save"])
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					dismiss()
				} label: {
					if #available(watchOS 26.0, *) {
						Image(systemName: "x.circle")
							.glassEffect(.clear)
							.foregroundStyle(.red)
					} else {
						Image(systemName: "x.circle.fill")
							.foregroundStyle(Color.red)
					}
				}
				.buttonStyle(.plain)
				.accessibilityLabel("Cancel and return to set list view")
				.accessibilityInputLabels(["Cancel"])
			}
		}
        .onAppear {
            stretch = totalStretch
            rest = totalRest
            reps = totalReps
            playlistToggle = isPlaylistActive
            audioToggle = audio
            hapticToggle = haptics
            volumeValue = promptVolume
        }
    }
}

struct WatchAppSettingsView: View {
    @Binding var stretch: Int
    @Binding var rest: Int
    @Binding var reps: Int
    
    var body: some View {
        List {
            NavigationLink(destination: StretchPickerView(stretch: $stretch)) {
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
			
            NavigationLink(destination: RestPickerView(rest: $rest)) {
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
            
            NavigationLink(destination: RepsPickerView(reps: $reps)) {
                HStack {
                    Text("Reps")
                        .font(.caption2)
                    Spacer()
                    Text("\(reps) reps")
                    .foregroundColor(.white)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Change the number of repetitions for each set")
            }
        }
    }
}

struct WatchDeviceSettingsView: View {
	// Properties stored in UserDefaults
    @Binding var playlistToggle: Bool
    @Binding var hapticToggle: Bool
    @Binding var audioToggle: Bool
    @Binding var volumeValue: Double
	
	//SwiftData query
	@Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
	
	//State properties
	@State private var isEditing = false
	@State private var isShowingEmptyPlaylistAlert = false
	
	@Binding var showAddExerciseView: Bool
    
    var body: some View {
        VStack {
			Toggle("Set list: \(playlistToggle ? "on" : "off")", isOn: $playlistToggle)
				.padding(.top, 10)
            Toggle("Audio: \(audioToggle ? "on" : "off")", isOn: $audioToggle)
                .accessibilityHint("Turn audio cues on or off")
            Toggle("Haptics: \(hapticToggle ? "on" : "off")", isOn: $hapticToggle)
                .accessibilityHint("Turn haptic feedback on or off")
            HStack {
                Slider(
                    value: $volumeValue,
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
                .accessibilityValue(String(volumeValue.formatted(.percent)))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: volumeValue += 0.1
                    case .decrement: volumeValue -= 0.1
                    @unknown default: print("not handled")
                    }
                }
            }
        }
        .padding([.horizontal, .vertical])
		.onChange(of: playlistToggle) {
			if playlistToggle && playlist.isEmpty {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					isShowingEmptyPlaylistAlert = true
				}
				
					playlistToggle = false
			}
		}
		.alert("Empty Setlists", isPresented: $isShowingEmptyPlaylistAlert) {
			Button("Add Exercise") {
				showAddExerciseView = true
			}
			Button("Cancel", role: .cancel) {}
		} message: {
			Text("There is nothing in the set list. \n Please add some exercises.")
		}
    }
}

// Subview for Stretch Picker
struct StretchPickerView: View {
    @Binding var stretch: Int
	
	var body: some View {
		VStack {
			Text("Stretch Duration").font(.headline)
			Picker("Stretch Duration", selection: $stretch) {
				ForEach(1...60, id: \.self) { Text("\($0) sec") }
			}
			.pickerStyle(.wheel)
			.labelsHidden()
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Stretch period is \(stretch) seconds")
			.accessibilityHint("Adjust how long to hold each stretch")
			.accessibilityValue(String(stretch))
			.accessibilityAdjustableAction { direction in
				switch direction {
				case .increment:stretch += 1
				case .decrement:stretch -= 1
				@unknown default: print("not handled")
				}
			}
		}
	}
}

// Subview for Rest Picker
struct RestPickerView: View {
    @Binding var rest: Int
	
	var body: some View {
		VStack {
			Text("Rest Duration").font(.headline)
			Picker("Rest Duration", selection: $rest) {
				ForEach(1...60, id: \.self) { Text("\($0) sec") }
			}
			.pickerStyle(.wheel)
			.labelsHidden()
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Rest period is \(rest) seconds")
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
	}
}

//Subview for Reps picker
struct RepsPickerView: View {
    @Binding var reps: Int
	
	var body: some View {
		VStack {
			Text("Reps").font(.headline)
            Picker("Number of Reps", selection: $reps) {
                ForEach(1...60, id:\.self) {
                    Text("\($0) reps")
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(reps) repetitions")
            .accessibilityHint("Adjust number of reps for each exercise")
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
}


#Preview {
	@Previewable @State var showExerciseView = false
	
    
	TimerSettingsViewWatch()
        .environment(Managers())
		.modelContainer(previewContainer)
}
