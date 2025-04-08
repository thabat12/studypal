//
//  CircularTimerView.swift
//  StudyPal
//
//  Created for Beta Release
//

import SwiftUI

struct CircularTimerView: View {
    var progress: Double
    var timeRemainingText: String
    var timerColor: Color
    var currentMode: TimerMode
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.2)
                .foregroundColor(timerColor)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(timerColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            // Timer text
            VStack(spacing: 10) {
                Text(currentMode.title)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text(timeRemainingText)
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .padding(30)
    }
}

#Preview {
    CircularTimerView(
        progress: 0.65,
        timeRemainingText: "15:30",
        timerColor: .blue,
        currentMode: .study
    )
} 