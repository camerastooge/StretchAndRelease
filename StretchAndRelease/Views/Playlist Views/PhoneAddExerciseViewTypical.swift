//
//  PhoneAddExerciseViewTypical.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/11/26.
//

import SwiftUI
import SwiftData

struct PhoneAddExerciseViewTypical: View {
    
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
    @FocusState private var focus: Bool
	
    var body: some View {
		VStack {
			Form {
				Section("Stretch name") {
					TextField("Name your stretch", text: $name)
                        .focused($focus)
						.textFieldStyle(.roundedBorder)
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
		}
        .onTapGesture {
            focus = false
        }
    }
}

#Preview {
	@Previewable @State var name = ""
	@Previewable @State var stretch = 10
	@Previewable @State var rest = 5
	@Previewable @State var reps = 4
	
	PhoneAddExerciseViewTypical(name: $name, stretch: $stretch, rest: $rest, reps: $reps)
}
