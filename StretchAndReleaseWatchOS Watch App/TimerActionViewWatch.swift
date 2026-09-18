//
//  TimerActionViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 5/27/26.
//

import SwiftUI
import SwiftData

struct TimerActionViewWatch: View {
    //Environment properties
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(StretchTimer.self) private var timer

    //SwiftData query
    @Query(sort: \PlaylistItem.index) var playlist: [PlaylistItem]

    @State private var didSettingsTriggerFromContentView = true

    //local properties for display
    var displayColor: Color {
        timer.isPaused ? Color.gray : timer.phase.phaseColor
    }

    var dragAccessibilityHint: String {
        if timer.isPlaylistActive {
            "Drag to the left to go to the previous stretch.  Drag to the right to go to the next exercise."
        } else {
            "This is the current stretch phase."
        }
    }

    var repetitionsLabel: String {
        switch dynamicTypeSize {
        case .xxLarge, .xxxLarge, .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return timer.repsLabel
        default:
            return "Reps: \(timer.repsLabel)"
        }
    }

    // variables for button view
    var deviceType: DeviceType = .watch

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0)

                ZStack {
                    GeometryReader { proxy in
                        Arc(endAngle: timer.endAngle)
                            .stroke(displayColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(Angle(degrees: 90))
                            .frame(width: proxy.size.width * 0.9, height: proxy.size.height, alignment: .center)
                            .position(x: proxy.size.width / 2, y: proxy.size.height * 0.45)
                    }

                    //Information display in center of arc
                    VStack {
                        Text("\(String(format: "%02d", timer.timeRemaining))")
                            .font(.largeTitle.monospacedDigit())
                            .kerning(2)
                            .contentTransition(.numericText())
                            .accessibilityLabel("\(timer.timeRemaining) seconds remaining")
                            .padding(.bottom, 5)

                        //Playlist buttons and Exercise text label
                        Grid {
                            GridRow {
                                HStack {
                                    if timer.isPlaylistActive {
                                        Button {
                                            timer.selectPreviousItem()
                                        } label: {
                                            Image(systemName: "arrowtriangle.left.fill")
                                                .foregroundStyle(.white)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel("Previous stretch")
                                        .accessibilityInputLabels(["previous", "previous stretch"])
                                    } else {
                                        Color.clear
                                    }
                                }
                                .frame(width: 8)

                                Text(timer.displayLabel)
                                    .frame(width: 80, height: 25)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.5)
                                    .contentTransition(.opacity)
                                    .gesture(
                                        DragGesture()
                                            .onEnded { gesture in
                                                guard timer.isPlaylistActive else { return }
                                                withAnimation(.linear(duration: 0.25)) {
                                                    if gesture.translation.width < 0 {
                                                        timer.selectPreviousItem()
                                                    } else if gesture.translation.width > 0 {
                                                        timer.selectNextItem()
                                                    }
                                                }
                                            }
                                    )
                                    .accessibilityLabel(timer.displayLabel)
                                    .accessibilityHint(dragAccessibilityHint)

                                HStack {
                                    if timer.isPlaylistActive {
                                        Button {
                                            timer.selectNextItem()
                                        } label: {
                                            Image(systemName: "arrowtriangle.right.fill")
                                                .foregroundStyle(.white)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel("Go to the next stretch")
                                        .accessibilityInputLabels(["next", "next stretch"])
                                    } else {
                                        Color.clear
                                    }
                                }
                                .frame(width: 8)
                            }
                            .frame(height: 20)
                        }
                        .offset(y: -8)

                        Text(repetitionsLabel)
                            .font(.title3)
                            .offset(y: -5)
                            .accessibilityLabel("Repetitions Completed \(timer.repsCompleted) of \(timer.totalReps)")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(displayColor)
                }
                .sensoryFeedback(.impact(intensity: timer.hapticsEnabled ? timer.phase.phaseIntensity : 0.0), trigger: timer.endAngle)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    //resets timer
                    Button {
                        timer.reset()
                    } label: {
                        ButtonView(buttonRoles: .reset, deviceType: deviceType)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing)
                    .accessibilityInputLabels(["Reset", "Reset Timer"])
                    .accessibilityLabel("Reset Timer")

                    //play-pause button
                    Button {
                        timer.togglePlayPause()
                    } label: {
                        ButtonView(buttonRoles: !timer.isActive ? .play : .pause, deviceType: deviceType)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing)
                    .accessibilityInputLabels(["Start", "Pause", "Start Timer", "Pause Timer"])
                    .accessibilityLabel("Start or Pause Timer")

                    //Settings
                    NavigationLink {
                        TimerSettingsViewWatch(didTriggerSettingsFromContentView: $didSettingsTriggerFromContentView)
                            .navigationBarBackButtonHidden()
                    } label: {
                        ButtonView(buttonRoles: .settings, deviceType: deviceType)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("show settings")
                    .accessibilityInputLabels(["settings"])
                }
            }
        }
        .onAppear {
            didSettingsTriggerFromContentView = true
        }

        //keep the timer's copy of the set list current
        .onChange(of: playlist, initial: true) {
            timer.syncPlaylist(playlist)
        }

        .onChange(of: timer.isPlaylistActive) {
            timer.syncPlaylist(playlist)
        }
    }
}

#Preview {
    TimerActionViewWatch()
        .environment(StretchTimer())
        .modelContainer(previewContainer)
}
