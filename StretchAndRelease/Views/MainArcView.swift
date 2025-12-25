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
    
    //Properties passed in from parent view
    var phaseColor: Color
    @Binding var endAngle: Angle
    @Binding var animationDuration: Double
    
    var body: some View {
        ZStack {
            if !differentiateWithoutColor {
                withAnimation(.linear(duration: animationDuration)) {
                    Arc(endAngle: endAngle)
                        .stroke(phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                        .rotationEffect(Angle(degrees: 90))
                        .shadow(color: colorScheme == .dark ? .gray.opacity(0.65) : .black.opacity(0.35), radius: 5, x: 8, y: 5)
                        .padding(.bottom)
                }
            } else {
                withAnimation(.linear(duration: animationDuration)) {
                    Arc(endAngle: endAngle)
                        .stroke(.black, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                        .rotationEffect(Angle(degrees: 90))
                        .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    @Previewable var phaseColor = Color.red
    @Previewable @State var endAngle = Angle(degrees: 340.0)
    @Previewable @State var animationDuration = 0.0
    MainArcView(phaseColor: phaseColor, endAngle: $endAngle, animationDuration: $animationDuration)
}
