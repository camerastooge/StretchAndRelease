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
            VStack {
//                if !differentiateWithoutColor {
//                    Arc(endAngle: timer.endAngle)
//                        .stroke(timer.phase.phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
//                        .rotationEffect(Angle(degrees: 90))
//                        .shadow(color: colorScheme == .dark ? .gray.opacity(0) : .black.opacity(0.35), radius: 5, x: 8, y: 5)
//                        .padding(.bottom)
//                        .position(x: proxy.size.width / 2)
//                        .offset(y: proxy.size.height * 0.55)
//                } else {
//                    Arc(endAngle: timer.endAngle)
//                        .stroke(.black, style: StrokeStyle(lineWidth: 25, lineCap: .round))
//                        .rotationEffect(Angle(degrees: 90))
//                        .padding(.bottom)
//                        .position(x: proxy.size.width / 2)
//                }

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
                
                
            Path { path in
                path.move(to: CGPoint(x: proxy.frame(in: .local).minX, y: proxy.frame(in: .local).maxY / 1.5))
                path.addLine(to: CGPoint(x: proxy.frame(in: .local).maxX, y: proxy.frame(in: .local).maxY / 1.5))
            }
            .stroke(timer.phase.phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
            }
            .frame(maxWidth: proxy.frame(in: .global).width, maxHeight: proxy.size.height * 0.4)
        }
    }
}

#Preview {
    MainArcViewLandscape()
        .environment(StretchTimer())
}
