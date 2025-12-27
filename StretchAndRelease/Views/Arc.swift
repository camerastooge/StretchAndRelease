//
//  Arc.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 8/3/25.
//

import SwiftUI

struct Arc: Shape {
    var endAngle: Angle
    
    var animatableData: Double {
        get {
            endAngle.degrees
        }
        set {
            endAngle = Angle(degrees: newValue)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: Angle(degrees:20), endAngle: endAngle, clockwise: false)
        return path
    }
}
