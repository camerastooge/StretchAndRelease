//
//  SplashView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/2/25.
//

// gradient circle that animates for two (three?) seconds while app loads

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SplashView()
}
