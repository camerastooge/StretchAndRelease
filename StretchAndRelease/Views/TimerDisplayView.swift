//
//  TimerDisplayView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 3/10/26.
//

import SwiftUI
import SwiftData

struct TimerDisplayView: View {
    //Environment properties
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(StretchTimer.self) private var timer

    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]

    // variables for button view
    var deviceType: DeviceType = .phone

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    MainArcView()
                }
            }
            .containerRelativeFrame([.horizontal, .vertical]) { size, axis in
                if axis == .vertical {
                    size * 0.70
                } else {
                    size * 0.85
                }
            }

            Group {
                // playlist button row
                if timer.isPlaylistActive {
                    ZStack {
                        Color.gray.opacity(differentiateWithoutColor ? 0 : 0.25)
                        HStack {
                            Spacer()

                            //PREVIOUS EXERCISE BUTTON
                            Button {
                                timer.selectPreviousItem()
                            } label: {
                                ButtonView(buttonRoles: .previousItem, deviceType: deviceType)
                                    .opacity(0.75)
                            }
                            .accessibilityLabel("Go to previous item in set list")
                            .accessibilityInputLabels(["Previous", "Previous Stretch"])

                            Spacer()

                            //NEXT EXERCISE BUTTON
                            Button {
                                timer.selectNextItem()
                            } label: {
                                ButtonView(buttonRoles: .nextItem, deviceType: deviceType)
                                    .opacity(0.75)
                            }
                            .accessibilityLabel("Go to next item in set list")
                            .accessibilityInputLabels(["Next", "Next Stretch"])

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical) { size, axis in
                        size * 0.1
                    }
                    .padding(.bottom, 10)
                } else {
                    Color.clear
                        .containerRelativeFrame(.vertical) { size, axis in
                            size * 0.1
                        }
                }

                //Normal Button Row
                ZStack {
                    Color.black.opacity(differentiateWithoutColor ? 0.0 : 0.25)
                    HStack {
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

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
                .frame(maxWidth: .infinity)
                .containerRelativeFrame(.vertical) { size, axis in
                    size * 0.1
                }
            }
        }
        .background {
            Color.clear
                .gradientBackground()
                .ignoresSafeArea()
        }

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
    TimerDisplayView()
        .environment(StretchTimer())
        .modelContainer(previewContainer)
}
