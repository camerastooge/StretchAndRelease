//
//  TimerActionViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 5/27/26.
//

import SwiftUI
import SwiftData

struct TimerDisplayViewWatch: View {
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
                                        .disabled(timer.phase != .stop)
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
                                            },
                                        isEnabled: timer.phase == .stop
                                    )
                                    .accessibilityLabel(timer.displayLabel)
                                    .accessibilityHint("This is the current stretch phase.")

                                HStack {
                                    if timer.isPlaylistActive {
                                        Button {
                                            timer.selectNextItem()
                                        } label: {
                                            Image(systemName: "arrowtriangle.right.fill")
                                                .foregroundStyle(.white)
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(timer.phase != .stop)
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
                .sensoryFeedback(.impact(intensity: timer.phase.phaseIntensity), trigger: timer.endAngle) { _, _ in
                    timer.hapticsEnabled
                }
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
                    .disabled(timer.isActive)
                    .accessibilityLabel("show settings")
                    .accessibilityInputLabels(["settings"])
                }
            }
            .onDisappear {
                timer.reset()
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
    TimerDisplayViewWatch()
        .environment(StretchTimer())
        .modelContainer(previewContainer)
}
