//
//  MainHelpScreenView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/19/25.
//

import SwiftUI

struct MainHelpScreenView: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var deviceType: DeviceType = .phone
    var buttonRole: ButtonRoles = .play
    
    var isScrollDisabled: Bool {
        switch sizeCategory {
        case .accessibility3, .accessibility4, .accessibility5: return false
        default: return true
        }
    }
    
    var privacyPolicyString: String {
        switch sizeCategory {
        case .accessibility3, .accessibility4, .accessibility5: return "Privacy Policy"
        default: return "View our Privacy Policy"
        }
    }
    
    let privacyURL: URL = URL(string: "https://camerastooge.github.io/sar-privacy-policy/") ?? URL(string: "https://camerastooge.github.io")!
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Grid(alignment: .leading, verticalSpacing: 20) {
                    GridRow {
                        VStack {
                            ButtonView(buttonRoles: .play, deviceType: deviceType)
                            ButtonView(buttonRoles: .pause, deviceType: deviceType)
                        }
                        .padding(.horizontal, 15)
                        Text("Starts or pauses the timer")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityHint("This graphic shows the play and pause icons.")
                    
                    GridRow {
                        ButtonView(buttonRoles: .reset, deviceType: deviceType)
                            .padding(.horizontal, 15)
                        Text("Resets the timer to your starting point")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityHint("The graphic shows the button to reset the timer.")
                    
                    GridRow {
                        ButtonView(buttonRoles: .settings, deviceType: deviceType)
                            .padding(.horizontal, 15)
                        Text("Access timer settings")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityHint("The settings button accesses the settings menu")
                    
                    GridRow {
                        ButtonView(buttonRoles: .previousItem, deviceType: deviceType)
                            .padding(.horizontal, 15)
                        Text("Previous item in set list")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Previous set list item button")
                    
                    GridRow {
                        ButtonView(buttonRoles: .nextItem, deviceType: deviceType)
                            .padding(.horizontal, 15)
                        Text("Next item in set list")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Next set list item button")
                }
            }
            .padding(.vertical, 10)
            .scrollDisabled(isScrollDisabled)
            
            Section {
                HStack {
                    Spacer()
                    Link(privacyPolicyString, destination: privacyURL)
                    Spacer()
                }
                .padding(.vertical, 8)
                .accessibilityLabel("View Our Privacy Policy")
                .accessibilityHint("The text links to an external web site.")
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

    #Preview {
        MainHelpScreenView()
    }
