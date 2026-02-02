//
//  View Modifiers.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/1/26.
//

import SwiftUI

struct BackGroundGradientView: ViewModifier {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.colorScheme) var colorScheme
    
    private var gradientChoice: [Color] {
        if colorScheme == .dark {
            if differentiateWithoutColor {
                [.gray, .gray]
            } else {
                [.black, .gray]
            }
        } else {
            [.gray, .white]
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(gradient: Gradient(colors: gradientChoice), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    
}

extension View {
    func gradientBackground() -> some View {
        self.modifier(BackGroundGradientView())
    }
}
