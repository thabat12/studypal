//
//  TimerSettingsModel.swift
//  StudyPal
//
//  Created for Beta Release
//

import Foundation
import SwiftUI

enum TimerMode {
    case study
    case shortBreak
    case longBreak
    
    var title: String {
        switch self {
        case .study:
            return "Study Session"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
    
    var defaultDuration: TimeInterval {
        switch self {
        case .study:
            return 25 * 60 // 25 minutes
        case .shortBreak:
            return 5 * 60 // 5 minutes
        case .longBreak:
            return 15 * 60 // 15 minutes
        }
    }
}

enum TimerState {
    case running
    case paused
    case stopped
}

class TimerSettingsModel: ObservableObject {
    @Published var studyDuration: TimeInterval = TimerMode.study.defaultDuration
    @Published var shortBreakDuration: TimeInterval = TimerMode.shortBreak.defaultDuration
    @Published var longBreakDuration: TimeInterval = TimerMode.longBreak.defaultDuration
    @Published var autoStartBreaks: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    @Published var sessionsBeforeLongBreak: Int = 4
    
    // Theme color for the timer
    @Published var timerColor: Color = .blue
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        studyDuration = defaults.double(forKey: "studyDuration") != 0 ? defaults.double(forKey: "studyDuration") : TimerMode.study.defaultDuration
        shortBreakDuration = defaults.double(forKey: "shortBreakDuration") != 0 ? defaults.double(forKey: "shortBreakDuration") : TimerMode.shortBreak.defaultDuration
        longBreakDuration = defaults.double(forKey: "longBreakDuration") != 0 ? defaults.double(forKey: "longBreakDuration") : TimerMode.longBreak.defaultDuration
        autoStartBreaks = defaults.object(forKey: "autoStartBreaks") as? Bool ?? true
        soundEnabled = defaults.object(forKey: "soundEnabled") as? Bool ?? true
        vibrationEnabled = defaults.object(forKey: "vibrationEnabled") as? Bool ?? true
        sessionsBeforeLongBreak = defaults.integer(forKey: "sessionsBeforeLongBreak") != 0 ? defaults.integer(forKey: "sessionsBeforeLongBreak") : 4
        
        if let colorData = defaults.data(forKey: "timerColor") {
            if let decodedColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
                self.timerColor = Color(decodedColor)
            }
        }
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(studyDuration, forKey: "studyDuration")
        defaults.set(shortBreakDuration, forKey: "shortBreakDuration")
        defaults.set(longBreakDuration, forKey: "longBreakDuration")
        defaults.set(autoStartBreaks, forKey: "autoStartBreaks")
        defaults.set(soundEnabled, forKey: "soundEnabled")
        defaults.set(vibrationEnabled, forKey: "vibrationEnabled")
        defaults.set(sessionsBeforeLongBreak, forKey: "sessionsBeforeLongBreak")
        
        let uiColor = UIColor(timerColor)
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false) {
            defaults.set(colorData, forKey: "timerColor")
        }
    }
    
    func getDuration(for mode: TimerMode) -> TimeInterval {
        switch mode {
        case .study:
            return studyDuration
        case .shortBreak:
            return shortBreakDuration
        case .longBreak:
            return longBreakDuration
        }
    }
    
    func resetToDefaults() {
        studyDuration = TimerMode.study.defaultDuration
        shortBreakDuration = TimerMode.shortBreak.defaultDuration
        longBreakDuration = TimerMode.longBreak.defaultDuration
        autoStartBreaks = true
        soundEnabled = true
        vibrationEnabled = true
        sessionsBeforeLongBreak = 4
        timerColor = .blue
        saveSettings()
    }
} 