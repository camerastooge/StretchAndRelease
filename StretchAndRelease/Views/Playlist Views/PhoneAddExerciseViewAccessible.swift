//
//  PhoneAddExerciseViewAccessible.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/11/26.
//

import SwiftUI

struct PhoneAddExerciseViewAccessible: View {
	//Environment properties
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
	@Environment(\.dynamicTypeSize) var sizeCategory
	@Environment(\.dismiss) var dismiss
	
	@Binding var name: String
	@Binding var stretch: Int
	@Binding var rest: Int
	@Binding var reps: Int
	
	@ScaledMetric var buttonWidth = 100
	
	var body: some View {
		VStack {
			Spacer()
			
			Section {
				TextField("Name Your Stretch", text: $name)
					.textFieldStyle(.roundedBorder)
			}
			.accessibilityElement(children: .combine)
			.accessibilityLabel("Name your stretch")
			
			Spacer()
			
			Section {
				HStack {
					Spacer()
					Text("Stretch")
						.font(.largeTitle)
					Picker("Stretch", selection: $stretch) {
						ForEach(1...60, id:\.self) {
							Text("\($0)")
								.font(.largeTitle)
						}
					}
					.pickerStyle(.menu)
					Spacer()
				}
				.padding(.bottom, 25)
				.font(.headline)
				.frame(height: 40)
			}
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Stretch duration: \(stretch) seconds")
			.accessibilityHint("Adjust how long you want to hold each stretch")
			.accessibilityValue(String(stretch))
			.accessibilityAdjustableAction { direction in
				switch direction {
				case .increment: stretch += 1
				case .decrement: stretch -= 1
				@unknown default: print("not handled")
				}
			}
			
			Spacer()
			
			Section {
				HStack {
					Spacer()
					Text("Rest")
						.font(.largeTitle)
					Picker("Rest", selection: $rest) {
						ForEach(1...60, id:\.self) {
							Text("\($0)")
								.font(.largeTitle)
						}
					}
					.pickerStyle(.menu)
					Spacer()
				}
				.padding(.bottom, 25)
				.font(.headline)
				.frame(height: 40)
			}
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Rest duration: \(rest) seconds")
			.accessibilityHint("Adjust how long you want to rest between stretches")
			.accessibilityValue(String(rest))
			.accessibilityAdjustableAction { direction in
				switch direction {
				case .increment: rest += 1
				case .decrement: rest -= 1
				@unknown default: print("not handled")
				}
			}
			
			Spacer()
			
			Section {
				HStack {
					Spacer()
					Text("Reps")
						.font(.largeTitle)
					Picker("Reps", selection: $reps) {
						ForEach(1...60, id:\.self) {
							Text("\($0)")
								.font(.largeTitle)
						}
					}
					.pickerStyle(.menu)
					Spacer()
				}
				.padding(.bottom, 25)
				.font(.headline)
				.frame(height: 40)
			}
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Repetition count: \(reps)")
			.accessibilityHint("How many timnes do you want to perform this stretch")
			.accessibilityValue(String(reps))
			.accessibilityAdjustableAction { direction in
				switch direction {
				case .increment: reps += 1
				case .decrement: reps -= 1
				@unknown default: print("not handled")
				}
			}
			
			Spacer()
		}
	}
}


#Preview {
	@Previewable @State var name = ""
	@Previewable @State var stretch = 10
	@Previewable @State var rest = 5
	@Previewable @State var reps = 4
	
    PhoneAddExerciseViewAccessible(name: $name, stretch: $stretch, rest: $rest, reps: $reps)
}
