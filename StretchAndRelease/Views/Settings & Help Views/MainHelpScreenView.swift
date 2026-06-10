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
    
    let privacyURL: URL = URL(string: "https://camerastooge.github.io/sar-privacy-policy/") ?? URL(string: "https://camerastooge.github.io")!
    
    var body: some View {
		NavigationStack {
			Form {
				Section("Main Timer Controls") {
					HStack {
						VStack {
							ButtonView(buttonRoles: .play, deviceType: deviceType)
							ButtonView(buttonRoles: .pause, deviceType: deviceType)
						}
						.padding(.trailing, 25)
						Text("Starts or pauses the timer")
					}
					.listRowInsets(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 0))
					.listRowSeparator(.hidden)
					.accessibilityHint("This graphic shows the play and pause icons.")
					
					HStack {
						ButtonView(buttonRoles: .reset, deviceType: deviceType)
							.padding(.trailing, 25)
						Text("Resets the timer to your starting point")
					}
					.listRowInsets(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 0))
					.listRowSeparator(.hidden)
					.accessibilityHint("The graphic shows the button to reset the timer.")
					
					HStack {
						ButtonView(buttonRoles: .settings, deviceType: deviceType)
							.padding(.trailing, 25)
						Text("Access timer settings")
					}
					.accessibilityHint("The settings button accesses the settings menu")
                 }
				
				Section("Set List Controls") {
					HStack {
						VStack(alignment: .leading) {
							HStack {
								ButtonView(buttonRoles: .previousItem, deviceType: deviceType)
									.padding(.trailing, 25)
								Text("Previous item in set list")
							}
							.accessibilityLabel("Previous set list item button")
							
							HStack {
								ButtonView(buttonRoles: .nextItem, deviceType: deviceType)
									.padding(.trailing, 25)
								Text("Next item in set list")
							}
							.accessibilityLabel("Next set list item button")
						}
					}
				}
                
                Section {
                    HStack {
                        Spacer()
                        Link("View Our Privacy Policy", destination: privacyURL)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .accessibilityLabel("View our privacy policy.")
                    .accessibilityHint("The text links to an external web site.")
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
    }
}

#Preview {
    MainHelpScreenView()
}
