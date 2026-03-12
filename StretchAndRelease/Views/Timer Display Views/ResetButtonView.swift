//
//  ResetButtonView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 3/12/26.
//

import SwiftUI

struct ResetButtonView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(Managers.self) var managers
    
    // Properties stored in UserDefaults
    @AppStorage("stretch")          private var totalStretch = 10
    @AppStorage("rest")             private var totalRest = 5
    @AppStorage("reps")             private var totalReps = 3
    
    // state variables used across views
    @Binding var timeRemaining: Int
    @Binding var repsCompleted: Int
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                managers.stopTimer()
            }
            repsCompleted = 0
            timeRemaining = totalStretch
        } label: {
            ButtonView(buttonRoles: .reset, deviceType: .phone)
        }
    }
}

#Preview {
    @Previewable @State var timeRemaining = 0
    @Previewable @State var repsCompleted = 0
    
    ResetButtonView(timeRemaining: $timeRemaining, repsCompleted: $repsCompleted)
        .environment(Managers())
}
