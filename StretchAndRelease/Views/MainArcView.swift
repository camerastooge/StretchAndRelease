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
    
    //Settings
    @EnvironmentObject var settings: Settings
    
    //Properties passed in from parent view
    @Binding var stretchPhase: StretchPhase
    @Binding var endAngle: Angle
    
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
        }
    }
}

#Preview {
    @Previewable @State var endAngle = Angle(degrees: 340.0)
    @Previewable @State var stretchPhase = StretchPhase.stop
    MainArcView(stretchPhase: $stretchPhase, endAngle: $endAngle)
        .environmentObject(Settings.previewData)
}
