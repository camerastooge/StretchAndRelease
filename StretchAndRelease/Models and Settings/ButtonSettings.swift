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
    func body(content: Content) -> some View {
        content
            .frame(width: 85, height: 50)
    }
}

struct WatchFrame: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 30, height: 30)
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


