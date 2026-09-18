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
    @Environment(StretchTimer.self) private var timer

    var body: some View {
        ZStack {
            if !differentiateWithoutColor {
                Arc(endAngle: timer.endAngle)
                    .stroke(timer.phase.phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(Angle(degrees: 90))
                    .shadow(color: colorScheme == .dark ? .gray.opacity(0) : .black.opacity(0.35), radius: 5, x: 8, y: 5)
                    .padding(.bottom)
            } else {
                Arc(endAngle: timer.endAngle)
                    .stroke(.black, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(Angle(degrees: 90))
                    .padding(.bottom)
            }

            VStack {
                Spacer()
                Text("\(String(format: "%02d", timer.timeRemaining))")
                    .kerning(2)
                    .contentTransition(.numericText())
                    .accessibilityLabel("\(timer.timeRemaining) seconds remaining")
                Text(timer.displayLabel)
                    .scaleEffect(0.75)
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
                    .accessibilityLabel(!timer.isPaused ? timer.displayLabel : "WORKOUT PAUSED")
                Text("Reps: \(timer.repsLabel)")
                    .accessibilityLabel("Repetitions Completed \(timer.repsCompleted) of \(timer.totalReps)")
                Spacer()
            }
            .font(.largeTitle)
            .foregroundStyle(differentiateWithoutColor ? .black : timer.isPaused ? .gray : timer.phase.phaseColor)
            .fontWeight(.bold)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .sensoryFeedback(.impact(intensity: timer.phase.phaseIntensity), trigger: timer.endAngle) { _, _ in
                timer.hapticsEnabled
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    MainArcView()
        .environment(StretchTimer())
}
