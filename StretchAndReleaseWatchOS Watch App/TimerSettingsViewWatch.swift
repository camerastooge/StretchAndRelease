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

    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Text("Stretch")
                        .font(.caption2)
                    
                    Spacer()
                    
                    Picker("Stretch Duration", selection: $totalStretch) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 20)
                    
                    Spacer()
                    
                    Text("sec.")
                        .font(.caption2)
                }
                
                HStack {
                    Text("Rest")
                        .font(.caption2)
                    
                    Spacer()
                    
                    Picker("Rest Duration", selection: $totalRest) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 50, height: 20)
                    .labelsHidden()
                    
                    Spacer()
                    
                    Text("sec.")
                        .font(.caption2)
                }
                
                HStack {
                    Text("Reps")
                        .font(.caption2)
                    
                    Spacer()
                    
                    Picker("Number of Repetitions", selection: $totalStretch) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 50, height: 20)
                    .labelsHidden()
                    
                    Spacer()
                    
                    Text("sec.")
                        .font(.caption2)
                }
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Button {
                        UserDefaults.standard.set(totalStretch, forKey: "totalStretch")
                        UserDefaults.standard.set(totalRest, forKey: "totalRest")
                        UserDefaults.standard.set(totalReps, forKey: "totalReps")
                        print("SETTINGS SAVED: \(totalStretch), \(totalRest), \(totalReps)")
                        dismiss()
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                            .font(.title)
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            print("SETTINGS VARIABLES: \(totalStretch), \(totalRest), \(totalReps)")
        }
    }
}

#Preview {
    @Previewable @State var totalStretch: Int = 0
    @Previewable @State var totalRest: Int = 0
    @Previewable @State var totalReps: Int = 0
    TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
}
