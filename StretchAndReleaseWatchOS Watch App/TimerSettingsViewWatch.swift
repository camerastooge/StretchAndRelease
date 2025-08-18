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
    @EnvironmentObject var timerSettings: TimerSettings
    @Binding var didSettingsChange: Bool
    
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
                    
                    Picker("Stretch Duration", selection: $timerSettings.totalStretch) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 30)
                    .frame(width: secondColumnWidth)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Adjust how long you want to hold each stretch")
                .accessibilityValue(String(timerSettings.totalStretch))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: timerSettings.totalStretch += 1
                    case .decrement: timerSettings.totalStretch -= 1
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
                    
                    Picker("Rest Duration", selection: $timerSettings.totalRest) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 30)
                    .frame(width: secondColumnWidth)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Adjust how long you want to rest between stretches")
                .accessibilityValue(String(timerSettings.totalRest))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: timerSettings.totalRest += 1
                    case .decrement: timerSettings.totalRest -= 1
                    default: print("not handled")
                    }
                 }
                .padding(.horizontal)
                
                HStack {
                    Text("Reps")
                        .font(.caption2)
                        .frame(width: firstColumnWidth)
                    
                    Spacer()
                    
                    Picker("Number of Repetitions", selection: $timerSettings.totalReps) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 30
                    )
                    .frame(width: secondColumnWidth)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint("Set the number of times you want to perform this stretch")
                .accessibilityValue(String(timerSettings.totalReps))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: timerSettings.totalReps += 1
                    case .decrement: timerSettings.totalReps -= 1
                    default: print("not handled")
                    }
                 }
                .padding(.horizontal)
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Button {
                        didSettingsChange = true
                        dismiss()
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                            .font(.title)
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .clipShape(Circle())
                            .frame(alignment: .bottom)
                    }
                    .accessibilityHint("Save your settings and return to the main screen")
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .navigationBarTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .padding(.horizontal)
            
        }

    }
}

#Preview {
    @Previewable @State var didSettingsChange: Bool = false
    TimerSettingsViewWatch(didSettingsChange: $didSettingsChange)
}
