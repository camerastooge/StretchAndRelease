//
//  MainArcView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/10/25.
//

import SwiftUI

struct MainArcView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(Managers.self) private var managers
    
    //Properties from AppStorage
    
    @AppStorage("haptics") private var haptics = true
    @AppStorage("playlist") private var playlist = false
    
    //Bindings from parent view
    @Binding var endAngle: Angle
    @Binding var timeRemaining: Int
    @Binding var totalReps: Int
    @Binding var repsCompleted: Int
    @Binding var playlistItemName: String?
    
    //label for timer text view
    var timerTextLabel: String {
        if let playlistItemName {
            return playlistItemName
        } else {
            return managers.stretchPhase.phaseText
        }
    }
    
    var body: some View {
        ZStack {
            if !differentiateWithoutColor {
                Arc(endAngle: endAngle)
                    .stroke(managers.stretchPhase.phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(Angle(degrees: 90))
                    .shadow(color: colorScheme == .dark ? .gray.opacity(0) : .black.opacity(0.35), radius: 5, x: 8, y: 5)
                    .padding(.bottom)
            } else {
                Arc(endAngle: endAngle)
                    .stroke(.black, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(Angle(degrees: 90))
                    .padding(.bottom)
            }
            
            VStack {
                Spacer()
                Text("\(String(format: "%02d", Int(timeRemaining)))")
                    .kerning(2)
                    .contentTransition(.numericText(countsDown: true))
                    .accessibilityLabel("\(timeRemaining) seconds remaining")
                Text(!managers.isTimerPaused ? timerTextLabel : "PAUSED")
                    .scaleEffect(0.75)
                    .accessibilityLabel(!managers.isTimerPaused ? timerTextLabel : "WORKOUT PAUSED")
                Text("Reps: \(repsCompleted)/\(totalReps)")
                    .accessibilityLabel("Repetitions Completed \(repsCompleted) of \(totalReps)")
                Spacer()
            }
            .font(.largeTitle)
            .foregroundStyle(differentiateWithoutColor ? .black : managers.isTimerPaused ? .gray : managers.stretchPhase.phaseColor)
            .fontWeight(.bold)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .sensoryFeedback(.impact(intensity: managers.stretchPhase.phaseIntensity), trigger: endAngle) { oldValue, newValue in
                    return haptics
            }
            .padding(.bottom)
            .containerRelativeFrame(.vertical, alignment: .bottom) { length, _ in
                length / 1.15
            }
        }
    }
}

#Preview {
    @Previewable @State var endAngle = Angle(degrees: 340.0)
    @Previewable @State var timeRemaining = 8
    @Previewable @State var totalReps = 5
    @Previewable @State var repsCompleted = 2
    @Previewable @State var playlistItemName: String? = "Test"
    MainArcView(endAngle: $endAngle, timeRemaining: $timeRemaining, totalReps: $totalReps, repsCompleted: $repsCompleted, playlistItemName: $playlistItemName)
}
