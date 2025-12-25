//
//  StretchPhase.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

    // enum for StretchPhase defined
    enum StretchPhase {
        case stretch, rest, paused, stop
        
        var phaseColor: Color {
            switch self {
            case .stretch: return .green
            case .rest: return .yellow
            case .paused: return .gray
            case .stop: return .red
            }
        }
        
        var phaseText: String {
            switch self {
            case .stretch: return "STRETCH"
            case .rest: return "REST"
            case .paused: return "PAUSED"
            case .stop: return "STOP"
            }
        }
        
        var phaseIntensity: Double {
            switch self {
            case .stretch: return 0.5
            case .rest: return 0.25
            case .paused: return 0.25
            case .stop: return 1.0
            }
        }
    }
