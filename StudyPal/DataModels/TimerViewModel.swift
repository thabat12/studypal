//
//  TimerViewModel.swift
//  StudyPal
//
//  Created for Beta Release
//

import Foundation
import SwiftUI
import UserNotifications

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var timerState: TimerState = .stopped
    @Published var currentMode: TimerMode = .study
    @Published var progress: Double = 1.0
    @Published var completedSessions: Int = 0
    
    private var initialTime: TimeInterval = 0
    private var timer: Timer?
    private var startDate: Date?
    private var backgroundDate: Date?
    
    // Reference to settings
    private var settings: TimerSettingsModel
    
    init(settings: TimerSettingsModel) {
        self.settings = settings
        self.timeRemaining = settings.studyDuration
        self.initialTime = settings.studyDuration
        
        // Request notification permissions when the app is first launched
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
        
        // Add observer for app moving to background and foreground
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func startTimer() {
        // Start or resume the timer
        if timerState == .stopped {
            // If starting fresh, set initial values
            initialTime = settings.getDuration(for: currentMode)
            timeRemaining = initialTime
            completedSessions = 0
        }
        
        timerState = .running
        startDate = Date()
        
        // Cancel any existing timer
        timer?.invalidate()
        
        // Create a new timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.1
                self.progress = self.timeRemaining / self.initialTime
            } else {
                self.timerDidComplete()
            }
        }
    }
    
    func pauseTimer() {
        timerState = .paused
        timer?.invalidate()
    }
    
    func resetTimer() {
        timerState = .stopped
        timer?.invalidate()
        timeRemaining = settings.getDuration(for: currentMode)
        initialTime = timeRemaining
        progress = 1.0
    }
    
    func changeMode(to mode: TimerMode) {
        currentMode = mode
        resetTimer()
    }
    
    private func timerDidComplete() {
        // Stop the timer
        timer?.invalidate()
        timerState = .stopped
        
        // Update session count if we just completed a study session
        if currentMode == .study {
            completedSessions += 1
            
            // Determine the next break type based on completed sessions
            if completedSessions % settings.sessionsBeforeLongBreak == 0 {
                currentMode = .longBreak
            } else {
                currentMode = .shortBreak
            }
        } else {
            // If we just completed a break, go back to study mode
            currentMode = .study
        }
        
        // Reset timer for the new mode
        timeRemaining = settings.getDuration(for: currentMode)
        initialTime = timeRemaining
        progress = 1.0
        
        // Send notification
        if settings.soundEnabled {
            sendNotification()
        }
        
        // Vibrate if enabled
        if settings.vibrationEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        // Auto-start next session if enabled
        if settings.autoStartBreaks {
            startTimer()
        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(currentMode.title) completed!"
        content.body = "Time to " + (currentMode == .study ? "take a break!" : "get back to studying!")
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Helper function to format time remaining as MM:SS
    func formattedTimeRemaining() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // App state handling
    @objc func appMovedToBackground() {
        // Store the time when app moved to background
        backgroundDate = Date()
    }
    
    @objc func appMovedToForeground() {
        // Only update if timer was running
        if timerState == .running, let backgroundDate = backgroundDate {
            let timeInBackground = Date().timeIntervalSince(backgroundDate)
            timeRemaining = max(0, timeRemaining - timeInBackground)
            
            // If timer would have completed, handle completion
            if timeRemaining <= 0 {
                timerDidComplete()
            } else {
                // Update progress
                progress = timeRemaining / initialTime
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 