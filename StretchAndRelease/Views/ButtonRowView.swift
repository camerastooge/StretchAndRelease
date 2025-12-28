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
    @EnvironmentObject var settings: Settings
    
    //Bindings
    @Binding var stretchPhase: StretchPhase
    @Binding var deviceType: DeviceType
    
    
    var body: some View {
        ZStack {
            Color.gray.opacity(differentiateWithoutColor ? 0.0 : 0.25)
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        switch stretchPhase {
                        case .stop, .paused: return {
                            stretchPhase = .stretch
                        }()
                        case .stretch, .rest : return {
                            stretchPhase = .paused
                        }()
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
}
