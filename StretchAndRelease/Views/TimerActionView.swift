//
//  TimerActionView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

//struct TimerActionView: View {
    
//    //bindings passed in from parent view
//    @Binding var isTimerActive: Bool
//    @Binding var isTimerPaused: Bool
//    @Binding var isResetToggled: Bool
//    @Binding var timeRemaining: Int
//    @Binding var repsCompleted: Int
//    @Binding var stretchPhase: StretchPhase
//    @Binding var timer: Timer
//    
//    //binding settings
//    @EnvironmentObject var timerSettings: TimerSettings
    
    //variables local to this view
//    @State private var endAngle = Angle(degrees: 340)

    
//    var body: some View {
//        ZStack {
//            ZStack {
//                Arc(endAngle: endAngle)
//                    .stroke(stretchPhase.phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
//                    .rotationEffect(Angle(degrees: 90))
//                    .padding(.bottom)
//                VStack {
//                    Text("\(String(format: "%02d", Int(timeRemaining)))")
//                        .kerning(2)
//                        .contentTransition(.numericText(countsDown: true))
//                        .accessibilityLabel("\(timeRemaining) seconds remaining")
//                    Text(!isTimerPaused ? stretchPhase.phaseText : "PAUSED")
//                        .scaleEffect(0.75)
//                        .accessibilityLabel(!isTimerPaused ? stretchPhase.phaseText : "WORKOUT PAUSED")
//                    Text("Reps Completed: \(repsCompleted)/\(timerSettings.totalReps)")
//                        .accessibilityLabel("Repetitions Completed \(repsCompleted) of \(timerSettings.totalReps)")
//                }
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundStyle(!isTimerPaused ? stretchPhase.phaseColor : .gray)
//                .sensoryFeedback(.impact(intensity: stretchPhase.phaseIntensity), trigger: endAngle)
//                .containerRelativeFrame(.vertical, alignment: .bottom) { length, _ in
//                    length / 1.15
//                }
//            }
//        }
//        .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
//            length * 0.9
//        }
//        .padding(.bottom, 40)
        
//        // this modifier activates when the values are changed in the settings
//        .onChange(of: [timerSettings.totalStretch, timerSettings.totalRest, timerSettings.totalReps]) {
//            withAnimation(.linear(duration: 0.5)) {
//                timeRemaining = timerSettings.totalStretch
//                isTimerPaused = false
//                isTimerActive = false
//                withAnimation(.linear(duration: 0.5)) {
//                    endAngle = Angle(degrees: 340)
//                }
//            }
//        }
//        
//        //reset button behavior
//        .onChange(of: isResetToggled) {
//            stretchPhase = .stop
//            timeRemaining = timerSettings.totalStretch
//            repsCompleted = 0
//            withAnimation(.easeInOut(duration: 0.5)) {
//                updateEndAngle()
//            }
//        }
//        
//        //this modifier runs when the timer publishes
//        .onReceive(timer) { _ in
//            if isTimerActive && !isTimerPaused {
//                switch stretchPhase {
//                case .stretch: return {
//                    if timeRemaining > 0 {
//                        timeRemaining -= 1
//                        withAnimation(.linear(duration: 1.0)) {
//                            updateEndAngle()
//                        }
//                        SoundManager.instance.playSound(sound: .tick)
//                    } else {
//                        repsCompleted += 1
//                        if repsCompleted < timerSettings.totalReps {
//                            stretchPhase = .rest
//                            SoundManager.instance.playSound(sound: .rest)
//                        } else {
//                            stretchPhase = .stop
//                            timeRemaining = timerSettings.totalStretch
//                            withAnimation(.linear(duration: 1.0)) {
//                                updateEndAngle()
//                            }
//                            SoundManager.instance.playSound(sound: .relax)
//                        }
//                    }
//                }()
//                    
//                case .rest: return {
//                    if timeRemaining < timerSettings.totalRest {
//                        timeRemaining += 1
//                        withAnimation(.linear(duration: 1.0)) {
//                            updateEndAngle()
//                        }
//                    } else {
//                        stretchPhase = .stretch
//                        timeRemaining = timerSettings.totalStretch
//                        SoundManager.instance.playSound(sound: .stretch)
//                    }
//                }()
//                    
//                case .stop: return {
//                    isTimerActive = false
//                }()
//                }
//            }
//        }
//    }
//    
//    //function to set end angle of arc
//    func updateEndAngle() {
//        switch stretchPhase {
//        case .stretch:
//            endAngle = Angle(degrees: Double(timeRemaining) / Double(timerSettings.totalStretch) * 320 + 20)
//        case .rest:
//            endAngle = Angle(degrees: Double(timeRemaining) / Double(timerSettings.totalRest) * 320 + 20)
//        case .stop:
//            endAngle = Angle(degrees: 340)
//        }
//    }
//}
//
//#Preview {
//    @Previewable @State var isTimerActive = false
//    @Previewable @State var isTimerPaused = false
//    @Previewable @State var isResetToggled = false
//    @Previewable @State var stretchPhase = StretchPhase.stretch
//    @Previewable @State var totalStretch = 10
//    @Previewable @State var totalRest = 5
//    @Previewable @State var totalReps = 3
//    
//    VStack {
//        TimerActionView(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, timeRemaining: $totalStretch, repsCompleted: $totalReps, stretchPhase: $stretchPhase)
//            .environmentObject(TimerSettings())
//    }
//}
