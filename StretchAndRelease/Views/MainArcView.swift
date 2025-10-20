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
    @Environment(\.sizeCategory) var sizeCategory
    
    //Bindings from parent view
    @Binding var stretchPhase: StretchPhase
    @Binding var haptics: Bool
    @Binding var isTimerActive: Bool
    @Binding var isTimerPaused: Bool
    @Binding var endAngle: Angle
    @Binding var timeRemaining: Int
    @Binding var totalReps: Int
    @Binding var repsCompleted: Int
    
    var body: some View {
        ZStack {
            if !differentiateWithoutColor {
                Arc(endAngle: endAngle)
                    .stroke(stretchPhase.phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(Angle(degrees: 90))
                    .shadow(color: colorScheme == .dark ? .gray.opacity(0.65) : .black.opacity(0.35), radius: 5, x: 8, y: 5)
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
                Text(!isTimerPaused ? stretchPhase.phaseText : "PAUSED")
                    .scaleEffect(0.75)
                    .accessibilityLabel(!isTimerPaused ? stretchPhase.phaseText : "WORKOUT PAUSED")
                Text("Reps: \(repsCompleted)/\(totalReps)")
                    .accessibilityLabel("Repetitions Completed \(repsCompleted) of \(totalReps)")
                Spacer()
            }
            .font(.largeTitle)
            .dynamicTypeSize(DynamicTypeSize.xxxLarge...)
            .foregroundStyle(differentiateWithoutColor ? .black : isTimerPaused ? .gray : stretchPhase.phaseColor)
            .fontWeight(.bold)
            .sensoryFeedback(.impact(intensity: haptics ? stretchPhase.phaseIntensity : 0.0), trigger: endAngle)
            .padding(.bottom)
            .containerRelativeFrame(.vertical, alignment: .bottom) { length, _ in
                length / 1.15
            }
        }
    }
}

#Preview {
    @Previewable @State var stretchPhase: StretchPhase = .stretch
    @Previewable @State var haptics = true
    @Previewable @State var isTimerActive = true
    @Previewable @State var isTimerPaused = false
    @Previewable @State var endAngle = Angle(degrees: 340.0)
    @Previewable @State var timeRemaining = 8
    @Previewable @State var totalReps = 5
    @Previewable @State var repsCompleted = 2
    MainArcView(stretchPhase: $stretchPhase, haptics: $haptics, isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, endAngle: $endAngle, timeRemaining: $timeRemaining, totalReps: $totalReps, repsCompleted: $repsCompleted)
}
