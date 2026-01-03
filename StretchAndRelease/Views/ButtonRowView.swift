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
    
    //Settings and Switches
    @EnvironmentObject var settings: Settings
    @Environment(Switches.self) var switches
    
    //Bindings
    @Binding var stretchPhase: StretchPhase
    @Binding var deviceType: DeviceType
    
    
    var body: some View {
        ZStack {
            Color.gray.opacity(differentiateWithoutColor ? 0.0 : 0.25)
            HStack {
                Spacer()
                
                Button {
                    withAnimation(.linear(duration: 0.25)) {
                        //start timer
                        if !switches.isTimerActive && !switches.isTimerPaused {
                            withAnimation(.linear(duration: 0.25)) {
                                stretchPhase = .stretch
                            }
                        }
                        
                        //pause timer
                        if switches.isTimerActive && !switches.isTimerPaused {
                            withAnimation(.linear(duration: 0.25)) {
                                stretchPhase = .paused
                            }
                        }
                        
                        //restart timer to stretch, mechanism will used isPhaseStretch to determine what route to take
                        if switches.isTimerPaused {
                            if switches.isPhaseStretch {
                                withAnimation(.linear(duration: 0.25)) {
                                    stretchPhase = .stretch
                                }
                            } else {
                                withAnimation(.linear(duration: 0.25)) {
                                    stretchPhase = .rest
                                }
                            }
                        }
                    }
                } label: {
                    ButtonView(buttonRoles: stretchPhase != .stretch ? .play : .pause, deviceType: deviceType)
                }
                .accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
                .accessibilityLabel("Start or Pause Timer")
                
                Spacer()
                
                Button {
                    stretchPhase = .stop
                    switches.isTimerActive = false
                    switches.isTimerPaused = false
                    switches.isPhaseStretch = false
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
}

#Preview {
    @Previewable @State var stretchPhase = StretchPhase.stop
    @Previewable @State var deviceType: DeviceType = .phone
    
    ButtonRowView(stretchPhase: $stretchPhase, deviceType: $deviceType)
        .environmentObject(Settings.previewData)
        .environment(Switches())
}
