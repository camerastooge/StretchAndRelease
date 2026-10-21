//
//  MainArcViewLandscape.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/16/26.
//

import SwiftUI

struct MainArcViewLandscape: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(StretchTimer.self) private var timer
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                //Text information display
                VStack {
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
                }
                .font(.largeTitle)
                .foregroundStyle(differentiateWithoutColor ? .black : timer.isPaused ? .gray : timer.phase.phaseColor)
                .fontWeight(.bold)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .sensoryFeedback(.impact(intensity: timer.phase.phaseIntensity), trigger: timer.endAngle) { _, _ in
                    timer.hapticsEnabled
                }
                .position(
                    x: proxy.size.width / 2,
                    y: proxy.size.height * 0.4
                )
                
                //Progress bar
                if !differentiateWithoutColor {
                    Capsule()
                        .fill(timer.phase.phaseColor)
                        .frame(width: max(25, proxy.size.width * timer.fraction), height: 25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.35), radius: 5, x: 8, y: 5)
                        .offset(y: proxy.frame(in: .local).maxY * -0.08)
                } else {
                    Capsule()
                        .fill(.black)
                        .frame(width: max(25, proxy.size.width * timer.fraction), height: 25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(y: proxy.frame(in: .local).maxY * -0.1)
                }
            }
        }
    }
}

#Preview {
    MainArcViewLandscape()
        .environment(StretchTimer())
}
