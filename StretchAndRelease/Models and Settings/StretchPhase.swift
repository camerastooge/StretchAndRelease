//
//  StretchPhase.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

    // enum for StretchPhase defined
    enum StretchPhase {
        case stretch, rest, stop
        
        var phaseColor: Color {
            switch self {
            case .stretch: return .green
            case .rest: return .yellow
            case .stop: return .red
            }
        }
        
        var phaseText: String {
            switch self {
            case .stretch: return "STRETCH"
            case .rest: return "REST"
            case .stop: return "STOP"
            }
        }
    }
