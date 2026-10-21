//
//  TimerProgressBar.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/21/26.
//

import SwiftUI

struct ProgressBar: Shape {
    var fraction: Double
    
    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var timerBarMaxWidth: Double = rect.maxX
        
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: timerBarMaxWidth * fraction, y: rect.midY))
        return path
    }
}
