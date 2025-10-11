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
    @Environment(\.sizeCategory) var sizeCategory
    
    var buttonRoles: ButtonRoles
    var deviceType: DeviceType
    
    var body: some View {
        if deviceType == .phone {
            if !differentiateWithoutColor {
                Image(systemName: buttonRoles.buttonImage)
                    .phoneFrame()
                    .foregroundStyle(.white)
                    .background(buttonRoles.buttonColor)
                    .clipShape(.capsule)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
            } else {
                Image(systemName: buttonRoles.buttonImage)
                    .phoneFrame()
                    .foregroundStyle(.black)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
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
