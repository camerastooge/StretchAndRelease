//
//  AnalogView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 12/22/25.
//

import SwiftUI

struct AnalogView: View {
    //Settings
    @EnvironmentObject var settings: Settings
    
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.sizeCategory) var sizeCategory
    
    @Binding var stretchPhase: StretchPhase
    @Binding var timeRemaining: Int
    @Binding var repCount: Int
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(String(format: "%02d", Int(timeRemaining)))")
                .scaleEffect(1.25)
                .kerning(2)
                .contentTransition(.numericText(countsDown: true))
                .accessibilityLabel("\(timeRemaining) seconds remaining")
            Text(stretchPhase.phaseText)
                .scaleEffect(0.75)
                .accessibilityLabel(stretchPhase.phaseText)
            Text("Reps: \(repCount)/\(settings.totalReps)")
                .accessibilityLabel("Repetition \(repCount) of \(settings.totalReps)")
            Spacer()
        }
        .font(.largeTitle)
        .dynamicTypeSize(DynamicTypeSize.xxxLarge...)
        .foregroundStyle(differentiateWithoutColor ? .black : stretchPhase.phaseColor)
        .fontWeight(.bold)
        .sensoryFeedback(.impact(intensity: settings.haptics ? stretchPhase.phaseIntensity : 0.0), trigger: timeRemaining)
        .padding(.bottom)
        .containerRelativeFrame(.vertical, alignment: .bottom) { length, _ in
            length / 1.15
        }
    }
}

#Preview {
    @Previewable @State var stretchPhase = StretchPhase.stop
    @Previewable @State var timeRemaining = 10
    @Previewable @State var repCount = 0
    AnalogView(stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repCount: $repCount)
        .environmentObject(Settings.previewData)
}
