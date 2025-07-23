//
//  TimerActionView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/13/25.
//

import SwiftUI

struct TimerActionView: View {
    
    //bindings passed in from parent view
    @Binding var isTimerActive: Bool
    @Binding var isTimerPaused: Bool
    @Binding var isResetToggled: Bool
    @Binding var stretchPhase: StretchPhase
    @Binding var timeRemaining: Int
    @Binding var repsCompleted: Int
    
    //binding settings
    @Binding var totalStretch: Int
    @Binding var totalRest: Int
    @Binding var totalReps: Int
    
    //variables local to this view
    @State private var endAngle = Angle(degrees: 340)
    
    //timer
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    
    //struct defines arc shape
    struct Arc: Shape {
        var endAngle: Angle
        
        var animatableData: Double {
            get { endAngle.degrees }
            set { endAngle = Angle(degrees: newValue) }
        }
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: Angle(degrees: 20), endAngle: endAngle, clockwise: false)
            return path
        }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Arc(endAngle: endAngle)
                    .stroke(stretchPhase.phaseColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(Angle(degrees: 90))
                VStack {
                    Text("\(String(format: "%02d", Int(timeRemaining)))")
                        .kerning(2)
                        .contentTransition(.numericText(countsDown: true))
                    Text(!isTimerPaused ? stretchPhase.phaseText : "PAUSED")
                        .scaleEffect(0.75)
                    Text("Reps Completed: \(repsCompleted)/\(totalReps)")
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(!isTimerPaused ? stretchPhase.phaseColor : .gray)
                .sensoryFeedback(.impact(intensity: stretchPhase.phaseIntensity), trigger: endAngle)
                .containerRelativeFrame(.vertical, alignment: .bottom) { length, _ in
                    length / 1.2
                }
                
            }
        }
        .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
            length * 0.9
        }
        
        // this modifier activates when the values are changed in the settings
        .onChange(of: [totalStretch, totalRest, totalReps]) {
            withAnimation(.linear(duration: 0.5)) {
                timeRemaining = totalStretch
                isTimerPaused = false
                isTimerActive = false
                withAnimation(.linear(duration: 0.5)) {
                    endAngle = Angle(degrees: 340)
                }
            }
        }
        
        //reset button behavior
        .onChange(of: isResetToggled) {
            stretchPhase = .stop
            timeRemaining = totalStretch
            repsCompleted = 0
            withAnimation(.linear(duration: 0.5)) {
                updateEndAngle()
            }
        }
        
        //this modifier runs when the timer publishes
        .onReceive(timer) { _ in
            if isTimerActive && !isTimerPaused {
                switch stretchPhase {
                case .stretch: return {
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                        withAnimation(.linear(duration: 1.0)) {
                            updateEndAngle()
                        }
                    } else {
                        repsCompleted += 1
                        if repsCompleted < totalReps {
                            stretchPhase = .rest
                            SoundManager.instance.playSound(sound: .chime)
                        } else {
                            stretchPhase = .stop
                            timeRemaining = totalStretch
                            withAnimation(.linear(duration: 1.0)) {
                                updateEndAngle()
                            }
                            SoundManager.instance.playSound(sound: .beep)
                        }
                    }
                }()
                    
                case .rest: return {
                    if timeRemaining < totalRest {
                        timeRemaining += 1
                        withAnimation(.linear(duration: 1.0)) {
                            updateEndAngle()
                        }
                    } else {
                        stretchPhase = .stretch
                        timeRemaining = totalStretch
                        SoundManager.instance.playSound(sound: .chime)
                    }
                }()
                    
                case .stop: return {
                    isTimerActive = false
                }()
                }
            }
        }
    }
    
    //function to set end angle of arc
    func updateEndAngle() {
        switch stretchPhase {
        case .stretch:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(totalStretch) * 320 + 20)
        case .rest:
            endAngle = Angle(degrees: Double(timeRemaining) / Double(totalRest) * 320 + 20)
        case .stop:
            endAngle = Angle(degrees: 340)
        }
    }
}

#Preview {
    @Previewable @State var isTimerActive = false
    @Previewable @State var isTimerPaused = false
    @Previewable @State var isResetToggled = false
    @Previewable @State var stretchPhase = StretchPhase.stretch
    @Previewable @State var totalStretch = 10
    @Previewable @State var totalRest = 5
    @Previewable @State var totalReps = 3
    
    VStack {
        TimerActionView(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, stretchPhase: $stretchPhase, timeRemaining: $totalStretch, repsCompleted: $totalReps, totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
    }
}
