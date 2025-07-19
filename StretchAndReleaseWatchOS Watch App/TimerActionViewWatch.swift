//
//  TimerActionViewWatch.swift
//  StretchAndReleaseWatchOS Watch App
//
//  Created by Lucas Barker on 6/14/25.
//

import SwiftUI

struct TimerActionViewWatch: View {
    
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
            Color.gray.opacity(0)
                
            ZStack {
                Arc(endAngle: endAngle)
                    .stroke(stretchPhase.phaseColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(Angle(degrees: 90))
                
                VStack {
                    Text("\(String(format: "%02d", Int(timeRemaining)))")
                        .font(.largeTitle)
                        .kerning(2)
                        .contentTransition(.numericText(countsDown: true))
                    Text(!isTimerPaused ? stretchPhase.phaseText : "PAUSED")
                        .scaleEffect(0.75)
                    Text("Reps: \(repsCompleted)/\(totalReps)")
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(!isTimerPaused ? stretchPhase.phaseColor : .gray)
                .sensoryFeedback(.impact(intensity: 1.0), trigger: endAngle)
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
        
        //this modifier runs when the timer publishes
        .onReceive(timer) { _ in
            if isTimerActive && !isTimerPaused {
                timeRemaining -= 1
                withAnimation(.linear(duration: 1.0)){
                    updateEndAngle()
                }
                print("End Angle: \(endAngle.degrees)")
                
                if timeRemaining == 0 {
                    //stop timer
                    timer.upstream.connect().cancel()
                    
                    //delay 1.0 seconds then perform phase change and reset end angle
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        switch stretchPhase {
                        case .stretch: return {
                            SoundManager.instance.playSound(sound: .chime)
                            stretchPhase = .rest
                            timeRemaining = totalRest
                            withAnimation(.linear(duration: 0.5)){
                                endAngle = Angle(degrees: 340)
                            }
                            timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
                        }()
                        case .rest: return {
                            repsCompleted += 1
                            if repsCompleted != totalReps {
                                SoundManager.instance.playSound(sound: .chime)
                                stretchPhase = .stretch
                                timeRemaining = totalStretch
                                withAnimation(.linear(duration: 0.5)){
                                    endAngle = Angle(degrees: 340)
                                }
                                timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
                            } else {
                                withAnimation(.linear(duration: 0.5)) {
                                    stretchPhase = .stop
                                    endAngle = Angle(degrees: 340)
                                }
                                SoundManager.instance.playSound(sound: .beep)
                            }
                        }()
                        case .stop: return { }()
                        }
                    }
                }
            }
        }
        
        .onChange(of: isResetToggled) {
            stretchPhase = .stop
            timeRemaining = totalStretch
            repsCompleted = 0
            withAnimation(.linear(duration: 0.5)){
                updateEndAngle()
            }
        }
        
        .onAppear {
            timeRemaining = totalStretch
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
        TimerActionViewWatch(isTimerActive: $isTimerActive, isTimerPaused: $isTimerPaused, isResetToggled: $isResetToggled, stretchPhase: $stretchPhase, timeRemaining: $totalStretch, repsCompleted: $totalReps, totalStretch: $totalStretch, totalRest: $totalRest, totalReps: $totalReps)
    }
}
