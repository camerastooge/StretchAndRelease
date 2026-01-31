//
//  ButtonSettings.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/10/25.
//

import SwiftUI

enum ButtonRoles {
    case play, pause, reset, settings, save
    
    var buttonImage: String {
        switch self {
            case .play: "play.fill"
            case .pause: "pause.fill"
            case .reset: "arrow.counterclockwise"
            case .settings: "gear"
            case .save: "square.and.arrow.up.circle"
        }
    }
    
    var buttonColor: Color {
        switch self {
        case .play: Color.green
        case .pause: Color.yellow
        case .reset: Color.red
        case .settings: Color.blue
        case .save: Color.green
        }
    }
}

enum DeviceType {
    case phone, watch
}

struct PhoneFrame: ViewModifier {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    private var phoneButtonFrameWidth: CGFloat {
        if differentiateWithoutColor {
            return 125
        } else {
            return 85
        }
    }
    
    private var phoneButtonFrameHeight: CGFloat {
        if differentiateWithoutColor {
            return 85
        } else {
            return 50
        }
    }
    
    func body(content: Content) -> some View {
        content
            .frame(width: phoneButtonFrameWidth, height: phoneButtonFrameHeight)
    }
}

struct WatchFrame: ViewModifier {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    private var watchButtonFrameWidth: CGFloat {
        if differentiateWithoutColor {
            return 50
        } else {
            return 30
        }
    }
    
    private var watchButtonFrameHeight: CGFloat {
        if differentiateWithoutColor {
            return 50
        } else {
            return 30
        }
    }
    
    func body(content: Content) -> some View {
        content
            .frame(width: watchButtonFrameWidth, height: watchButtonFrameHeight)
    }
}


extension View {
    func phoneFrame() -> some View {
        self.modifier(PhoneFrame())
    }

    func watchFrame() -> some View {
        self.modifier(WatchFrame())
    }

}


