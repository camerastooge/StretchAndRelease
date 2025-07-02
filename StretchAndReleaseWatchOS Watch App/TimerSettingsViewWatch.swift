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
        GeometryReader { proxy in
            let firstColumnWidth = proxy.size.width * (2/5)
            let secondColumnWidth = proxy.size.width * (1.5/5)
            let thirdColumnWidth = proxy.size.width * (2/5)
            
            NavigationStack {
                HStack {
                    Text("Stretch")
                        .font(.caption2)
                        .frame(width: firstColumnWidth)
                    
                    Spacer()
                    
                    Picker("Stretch Duration", selection: $totalStretch) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 20)
                    .frame(width: secondColumnWidth)
                    
                    Spacer()
                    
                    Text("sec.")
                        .font(.caption2)
                        .frame(width: thirdColumnWidth)
                }
                .padding(.trailing)
                
                HStack {
                    Text("Rest")
                        .font(.caption2)
                        .frame(width: firstColumnWidth)
                    
                    Spacer()
                    
                    Picker("Rest Duration", selection: $totalRest) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 20)
                    .frame(width: secondColumnWidth)
                    
                    Spacer()
                    
                    Text("sec.")
                        .font(.caption2)
                        .frame(width: thirdColumnWidth)
                }
                .padding(.trailing)
                
                HStack {
                    Text("Reps")
                        .font(.caption2)
                        .frame(width: firstColumnWidth)
                    
                    Spacer()
                    
                    Picker("Number of Repetitions", selection: $totalReps) {
                        ForEach(1...30, id:\.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 50, height: 20)
                    .frame(width: secondColumnWidth)
                    
                    Spacer()
                    
                    Text("sec.")
                        .font(.caption2)
                        .frame(width: thirdColumnWidth)
                }
                .padding(.trailing)
                
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
                            .frame(alignment: .bottom)
                    }
                    
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
    @Previewable @State var totalStretch: Int = 0
    @Previewable @State var totalRest: Int = 0
    @Previewable @State var totalReps: Int = 0
    TimerSettingsViewWatch(totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
}
