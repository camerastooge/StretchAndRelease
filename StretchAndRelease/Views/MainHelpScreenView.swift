//
//  MainHelpScreenView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/19/25.
//

import SwiftUI

struct MainHelpScreenView: View {
    var deviceType: DeviceType = .phone
    var buttonRole: ButtonRoles = .play
    
    var body: some View {
        Form {
            Section {
                HStack {
                    ButtonView(buttonRoles: .play, deviceType: deviceType)
                        .padding(.trailing, 25)
                    Text("Starts the timer")
                }
             }
            
            Section {
                HStack {
                    ButtonView(buttonRoles: .pause, deviceType: deviceType)
                        .padding(.trailing, 25)
                    Text("Pauses the timer")
                }
            }
            
            Section {
                HStack {
                    ButtonView(buttonRoles: .reset, deviceType: deviceType)
                        .padding(.trailing, 25)
                    Text("Resets the timer to your starting point")
                }
            }
            
            Section {
                HStack {
                    ButtonView(buttonRoles: .settings, deviceType: deviceType)
                        .padding(.trailing, 25)
                    Text("Access timer settings")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainHelpScreenView()
}
