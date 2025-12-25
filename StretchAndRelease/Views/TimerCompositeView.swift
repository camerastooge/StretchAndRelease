//
//  TimerCompositeView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 12/25/25.
//

import SwiftUI

struct TimerCompositeView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.sizeCategory) var sizeCategory
    
    //Settings
    @StateObject var settings = Settings()
    
    //Bindings passed from composite view
    @Binding var stretchPhase: StretchPhase
    @Binding var endAngle: Angle
    @Binding var timeRemaining: Int
    @Binding var repsCompleted: Int
    
    @State private var animationDuration: Double = 10
    
    var phaseColor: Color {
        switch stretchPhase {
        case .stretch: return Color.green
        case .rest: return Color.yellow
        case .paused: return Color.gray
        case .stop: return Color.red
        }
    }
    
    
    
    var body: some View {
        VStack {
            ZStack {
                MainArcView(phaseColor: phaseColor, endAngle: $endAngle, animationDuration: $animationDuration)
                    .padding(.bottom, 450)
                AnalogView(stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted)
            }
            .padding(.top, 325)
        }
    }
}

#Preview {
    @Previewable @State var stretchPhase: StretchPhase = .stop
    @Previewable @State var endAngle: Angle = .degrees(340)
    @Previewable @State var timeRemaining = 10
    @Previewable @State var repsCompleted = 0
    
    TimerCompositeView(stretchPhase: $stretchPhase, endAngle: $endAngle, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted)
}
