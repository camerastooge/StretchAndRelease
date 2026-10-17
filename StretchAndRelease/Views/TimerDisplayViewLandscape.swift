//
//  TimerDisplayViewPhoneLandscape.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 10/11/26.
//

import SwiftUI
import SwiftData

struct TimerDisplayViewLandscape: View {
    //Envirionment properties
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(StretchTimer.self) private var timer
    
    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]
    
    //properties for button view
    var deviceType: DeviceType = .phone
    
    var body: some View {
        HStack {
            if timer.isPlaylistActive {
                VStack {
                    //Previous exercise button
                    Button {
                        timer.selectPreviousItem()
                    } label: {
                        ButtonView(buttonRoles: .previousItem, deviceType: deviceType)
                            .opacity(0.75)
                    }
                    .accessibilityLabel("Go to previous item in set list")
                    .accessibilityInputLabels(["Previous", "Previous Stretch"])
                    
                    //START - PAUSE BUTTON
                    Button {
                        timer.togglePlayPause()
                    } label: {
                        if #available(iOS 26.0, *) {
                            ButtonView(buttonRoles: !timer.isActive ? .play : .pause, deviceType: deviceType)
                                .glassEffect()
                        } else {
                            ButtonView(buttonRoles: !timer.isActive ? .play : .pause, deviceType: deviceType)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(!timer.isActive ? "Start Timer" : "Pause Timer")
                    .accessibilityInputLabels(["Start", "Start Timer", "Pause", "Pause Timer"])
                }
            } else {
                VStack {
                    Spacer()
                    
                    //START - PAUSE BUTTON
                    Button {
                        timer.togglePlayPause()
                    } label: {
                        if #available(iOS 26.0, *) {
                            ButtonView(buttonRoles: !timer.isActive ? .play : .pause, deviceType: deviceType)
                                .glassEffect()
                        } else {
                            ButtonView(buttonRoles: !timer.isActive ? .play : .pause, deviceType: deviceType)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(!timer.isActive ? "Start Timer" : "Pause Timer")
                    .accessibilityInputLabels(["Start", "Start Timer", "Pause", "Pause Timer"])
                }
            }
                
                
                GeometryReader { proxy in
                    MainArcViewLandscape()
                        .position(
                            x: proxy.size.width / 2,
                            y: proxy.size.height * 0.5
                        )
                        .frame(
                            width: proxy.size.width * 0.9
                        )
                }
                
            if timer.isPlaylistActive {
                VStack {
                    //Next exercise button
                    Button {
                        timer.selectNextItem()
                    } label: {
                        ButtonView(buttonRoles: .nextItem, deviceType: deviceType)
                            .opacity(0.75)
                    }
                    .accessibilityLabel("Go to next item in set list")
                    .accessibilityInputLabels(["Next", "Next Stretch"])
                    
                    //RESET BUTTON
                    Button {
                        timer.reset()
                    } label: {
                        ButtonView(buttonRoles: .reset, deviceType: .phone)
                    }
                    .accessibilityLabel("Reset Timer")
                    .accessibilityHint("This button reset the timer.")
                    .accessibilityInputLabels(["Reset", "Reset Timer"])
                }
            } else {
                VStack {
                    Spacer()
                    
                    //RESET BUTTON
                    Button {
                        timer.reset()
                    } label: {
                        ButtonView(buttonRoles: .reset, deviceType: .phone)
                    }
                    .accessibilityLabel("Reset Timer")
                    .accessibilityHint("This button reset the timer.")
                    .accessibilityInputLabels(["Reset", "Reset Timer"])
                }
            }
            }
        .background {
            Color.clear
                .gradientBackground()
                .ignoresSafeArea()
        }
        .safeAreaPadding([.top, .bottom])
        

        //keep the timer's copy of the set list current
        .onChange(of: playlist, initial: true) {
            timer.syncPlaylist(playlist)
        }

        .onChange(of: timer.isPlaylistActive) {
            timer.syncPlaylist(playlist)
        }

        .onDisappear {
            timer.reset()
        }
    }
}

#Preview {
    TimerDisplayViewLandscape()
        .environment(StretchTimer())
        .modelContainer(previewContainer)
}
