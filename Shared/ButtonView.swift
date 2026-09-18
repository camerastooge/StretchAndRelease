//
//  ButtonView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/10/25.
//

import SwiftUI

struct ButtonView: View {    
    
    //Environment properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var buttonRoles: ButtonRoles
    var deviceType: DeviceType
    var buttonPadding: CGFloat {
        switch sizeCategory {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: 2
        default: 5
        }
    }
    
    var body: some View {
        if deviceType == .phone {
            if !differentiateWithoutColor {
                Image(systemName: buttonRoles.buttonImage)
                    .phoneFrame()
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding([.vertical, .horizontal], buttonPadding)
                    .background(buttonRoles.buttonColor)
                    .clipShape(.capsule)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility4)
            } else {
                Image(systemName: buttonRoles.buttonImage)
                    .phoneFrame()
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                    .padding([.horizontal, .vertical], buttonPadding)
                    .background(colorScheme == .dark ? Color(white: 0.85) : Color.clear, in: .capsule)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility4)
            }
        } else {
            if !differentiateWithoutColor {
                Image(systemName: buttonRoles.buttonImage)
                    .watchFrame()
                    .foregroundStyle(.white)
                    .background(buttonRoles.buttonColor)
                    .clipShape(.circle)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
            } else {
                Image(systemName: buttonRoles.buttonImage)
                    .watchFrame()
                    .foregroundStyle(.black)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
            }
        }
        
    }
}

#Preview {
    @Previewable @State var buttonRoles: ButtonRoles = .play
    @Previewable @State var deviceType: DeviceType = .phone
    ButtonView(buttonRoles: buttonRoles, deviceType: deviceType)
}
