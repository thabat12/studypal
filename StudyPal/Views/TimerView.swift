//
//  TimerView.swift
//  StudyPal
//
//  Created for Beta Release
//

import SwiftUI

struct TimerView: View {
    @StateObject private var settings = TimerSettingsModel()
    @StateObject private var viewModel: TimerViewModel
    @State private var showSettings = false
    @EnvironmentObject private var appState: AppState
    
    init() {
        // We need to create the settings model first, then pass it to the view model
        let settingsModel = TimerSettingsModel()
        _settings = StateObject(wrappedValue: settingsModel)
        _viewModel = StateObject(wrappedValue: TimerViewModel(settings: settingsModel))
    }
    
    // Extract the circular timer view into a function to break up complex expression
    @ViewBuilder
    private func buildTimerView() -> some View {
        CircularTimerView(
            progress: viewModel.progress,
            timeRemainingText: viewModel.formattedTimeRemaining(),
            timerColor: settings.timerColor,
            currentMode: viewModel.currentMode
        )
        .frame(height: 300)
    }
    
    // Extract timer mode selector to break up complex expression
    @ViewBuilder
    private func buildTimerModeSelector() -> some View {
        HStack(spacing: 15) {
            ForEach([TimerMode.study, TimerMode.shortBreak, TimerMode.longBreak], id: \.self) { mode in
                Button(action: {
                    viewModel.changeMode(to: mode)
                }) {
                    let isCurrentMode = viewModel.currentMode == mode
                    let foregroundColor = isCurrentMode ? Color.white : settings.timerColor
                    let backgroundColor = isCurrentMode ? settings.timerColor : Color.clear
                    
                    Text(mode.title)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .foregroundColor(foregroundColor)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(backgroundColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(settings.timerColor, lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(.horizontal)
    }
    
    // Extract timer controls to break up complex expression
    @ViewBuilder
    private func buildTimerControls() -> some View {
        HStack(spacing: 30) {
            // Reset button
            Button(action: {
                viewModel.resetTimer()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.gray)
            }
            
            // Start/Pause button
            Button(action: {
                if viewModel.timerState == .running {
                    viewModel.pauseTimer()
                } else {
                    viewModel.startTimer()
                }
            }) {
                let iconName = viewModel.timerState == .running ? "pause.fill" : "play.fill"
                
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .foregroundColor(settings.timerColor)
            }
            .padding(20)
            .background(
                Circle()
                    .stroke(settings.timerColor, lineWidth: 2)
            )
            
            // Settings button
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 20)
    }
    
    // Extract session description to break up complex expression
    @ViewBuilder
    private func buildSessionDescription() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("About Focus Timer")
                .font(.headline)
            
            Text("The StudyPal Focus Timer uses the Pomodoro Technique to help you study more effectively. Work for a set period, then take a short break. After completing several work sessions, take a longer break.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Session counter
                HStack {
                    Text("Sessions completed:")
                        .foregroundColor(.gray)
                    Text("\(viewModel.completedSessions)")
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Circular timer - using extracted function
                buildTimerView()
                
                // Timer mode selector - using extracted function
                buildTimerModeSelector()
                
                // Timer controls - using extracted function
                buildTimerControls()
                
                // Session description - using extracted function
                buildSessionDescription()
            }
            .padding(.bottom, 100)
            .padding(.top)
        }
        .navigationTitle("Focus Timer")
        .sheet(isPresented: $showSettings) {
            TimerSettingsView(settings: settings)
        }
        .onAppear {
            // Hide the tab bar when this view appears
            appState.showTab = false
        }
        .onDisappear {
            // Show the tab bar when this view disappears
            appState.showTab = true
        }
    }
}

// Extracted color circle view to break up complex expressions
struct ColorCircleView: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        let strokeWidth = isSelected ? 2.0 : 0.0
        
        Circle()
            .fill(color)
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(Color.primary, lineWidth: strokeWidth)
            )
            .onTapGesture(perform: action)
            .padding(5)
    }
}

struct TimerSettingsView: View {
    @ObservedObject var settings: TimerSettingsModel
    @Environment(\.dismiss) private var dismiss
    
    // Temporary state for settings
    @State private var studyDuration: Double = 0
    @State private var shortBreakDuration: Double = 0
    @State private var longBreakDuration: Double = 0
    @State private var autoStartBreaks: Bool = true
    @State private var soundEnabled: Bool = true
    @State private var vibrationEnabled: Bool = true
    @State private var sessionsBeforeLongBreak: Double = 4
    @State private var timerColor: Color = .blue
    
    // Available colors
    let colorOptions: [Color] = [.blue, .red, .green, .orange, .purple, .pink]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer Durations (Minutes)")) {
                    HStack {
                        Text("Study Session")
                        Spacer()
                        Text("\(Int(studyDuration))")
                    }
                    Slider(value: $studyDuration, in: 1...60, step: 1)
                    
                    HStack {
                        Text("Short Break")
                        Spacer()
                        Text("\(Int(shortBreakDuration))")
                    }
                    Slider(value: $shortBreakDuration, in: 1...30, step: 1)
                    
                    HStack {
                        Text("Long Break")
                        Spacer()
                        Text("\(Int(longBreakDuration))")
                    }
                    Slider(value: $longBreakDuration, in: 1...45, step: 1)
                }
                
                Section(header: Text("Session Count")) {
                    HStack {
                        Text("Sessions before long break")
                        Spacer()
                        Text("\(Int(sessionsBeforeLongBreak))")
                    }
                    Slider(value: $sessionsBeforeLongBreak, in: 1...10, step: 1)
                }
                
                Section(header: Text("Timer Color")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(colorOptions, id: \.self) { color in
                                ColorCircleView(
                                    color: color,
                                    isSelected: timerColor == color,
                                    action: { timerColor = color }
                                )
                            }
                        }
                    }
                }
                
                Section(header: Text("Behavior")) {
                    Toggle("Auto-start breaks", isOn: $autoStartBreaks)
                    Toggle("Sound notifications", isOn: $soundEnabled)
                    Toggle("Vibration", isOn: $vibrationEnabled)
                }
                
                Section {
                    Button(action: {
                        settings.resetToDefaults()
                        loadSettings()
                    }) {
                        Text("Reset to Defaults")
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Timer Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveSettings()
                        dismiss()
                    }) {
                        Text("Save")
                    }
                }
            }
            .onAppear {
                loadSettings()
            }
        }
    }
    
    private func loadSettings() {
        studyDuration = settings.studyDuration / 60
        shortBreakDuration = settings.shortBreakDuration / 60
        longBreakDuration = settings.longBreakDuration / 60
        autoStartBreaks = settings.autoStartBreaks
        soundEnabled = settings.soundEnabled
        vibrationEnabled = settings.vibrationEnabled
        sessionsBeforeLongBreak = Double(settings.sessionsBeforeLongBreak)
        timerColor = settings.timerColor
    }
    
    private func saveSettings() {
        settings.studyDuration = studyDuration * 60
        settings.shortBreakDuration = shortBreakDuration * 60
        settings.longBreakDuration = longBreakDuration * 60
        settings.autoStartBreaks = autoStartBreaks
        settings.soundEnabled = soundEnabled
        settings.vibrationEnabled = vibrationEnabled
        settings.sessionsBeforeLongBreak = Int(sessionsBeforeLongBreak)
        settings.timerColor = timerColor
        settings.saveSettings()
    }
}

#Preview {
    TimerView()
} 