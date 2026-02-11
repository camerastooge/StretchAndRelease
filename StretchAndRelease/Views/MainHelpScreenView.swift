//
//  MainHelpScreenView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/19/25.
//

import SwiftUI
import WebKit

struct MainHelpScreenView: View {
    var deviceType: DeviceType = .phone
    var buttonRole: ButtonRoles = .play
    
    let privacyURL = URL(filePath: "https://camerastooge.github.io/sar-privacy-policy")
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        VStack {
                            ButtonView(buttonRoles: .play, deviceType: deviceType)
                            ButtonView(buttonRoles: .pause, deviceType: deviceType)
                        }
                        .padding(.trailing, 25)
                        Text("Starts or pauses the timer")
                    }
                    .accessibilityHint("The play button starts the timer, then pauses when tapped again")
                 }
                
                Section {
                    HStack {
                        ButtonView(buttonRoles: .reset, deviceType: deviceType)
                            .padding(.trailing, 25)
                        Text("Resets the timer to your starting point")
                    }
                    .accessibilityHint("The reset button resets the timer to your starting values")
                }
                
                Section {
                    HStack {
                        ButtonView(buttonRoles: .settings, deviceType: deviceType)
                            .padding(.trailing, 25)
                        Text("Access timer settings")
                    }
                    .accessibilityHint("The settings button accesses the settings menu")
                }
                
                Section {
                    HStack {
                        Spacer()
                        Link("View Our Privacy Policy", destination: privacyURL)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainHelpScreenView()
}
