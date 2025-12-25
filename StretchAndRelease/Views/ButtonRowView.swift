//
//  ButtonRowView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 12/25/25.
//

import SwiftUI

struct ButtonRowView: View {
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.sizeCategory) var sizeCategory
    
    //Settings
    @StateObject var settings = Settings()
    
    //Bindings
    @Binding var isTimerActive: Bool
    @Binding var isTimerPaused: Bool
    @Binding var stretchPhase: StretchPhase
    @Binding var timeRemaining: Int
    @Binding var repsCompleted: Int
    @Binding var endAngle: Angle
    @Binding var deviceType: DeviceType
    
    
    var body: some View {
        ZStack {
            Color.gray.opacity(differentiateWithoutColor ? 0.0 : 0.25)
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        if stretchPhase == .stop {
                            if settings.audio {
                                SoundManager.instance.playPrompt(sound: .countdownExpanded)
                            }
                            DispatchQueue.main.asyncAfter(deadline: settings.audio ? .now() + 3.0 : .now() + 0.5) {
                                withAnimation(.linear(duration: 0.25)) {
                                    isTimerActive = true
                                    isTimerPaused = false
                                    stretchPhase = .stretch
                                    repsCompleted = 0
                                }
                            }
                        } else if !isTimerPaused {
                            isTimerPaused = true
                            isTimerActive = false
                        } else {
                            if settings.audio {
                                SoundManager.instance.playPrompt(sound: .countdownExpanded)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.linear(duration: 0.25)) {
                                    isTimerPaused = false
                                    isTimerActive = true
                                }
                            }
                        }
                    }
                } label: {
                    ButtonView(buttonRoles: !isTimerActive ? .play : .pause, deviceType: deviceType)
                }
                .accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
                .accessibilityLabel("Start or Pause Timer")
                
                Spacer()
                
                Button {
                    isTimerActive = false
                    isTimerPaused = false
                    repsCompleted = 0
                    stretchPhase = .stop
                    timeRemaining = settings.totalStretch
                    withAnimation(.easeInOut(duration: 0.5)) {
                        updateEndAngle()
                    }
                } label: {
                    ButtonView(buttonRoles: .reset, deviceType: .phone)
                }
                .accessibilityInputLabels(["Reset", "Reset Timer"])
                .accessibilityLabel("Reset Timer")
                
                Spacer()
            }
            .padding([.horizontal, .vertical])
        }
    }
    
    //function to set end angle of arc
    func updateEndAngle() {
        switch stretchPhase {
        case .stretch, .rest:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(settings.totalStretch) * 320 + 20)
        case .stop, .paused:
            endAngle = Angle(degrees: 340)
        }
    }
}

#Preview {
    @Previewable @State var stretchPhase = StretchPhase.stop
    @Previewable @State var isTimerActive = false
    @Previewable @State var isTimerPaused = false
    @Previewable @State var timeRemaining: Int = 10
    @Previewable @State var repsCompleted = 0
    @Previewable @State var endAngle = Angle(degrees: 340)
    @Previewable @State var deviceType: DeviceType = .phone
    
    ButtonRowView(settings: Settings.previewData, isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, stretchPhase: $stretchPhase, timeRemaining: $timeRemaining, repsCompleted: $repsCompleted, endAngle: $endAngle, deviceType: $deviceType)
}
