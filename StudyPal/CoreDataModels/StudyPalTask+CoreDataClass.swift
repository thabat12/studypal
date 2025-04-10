//
//  StudyPalTask+CoreDataClass.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/29/25.
//
//

import Foundation
import CoreData

@objc(StudyPalTask)
public class StudyPalTask: NSManagedObject {
    // Core Data already provides Identifiable conformance
}

// MARK: - StudyPalTask Extension
extension StudyPalTask {
    var isAllDay: Bool {
        get {
            // Use the 'times' property to store the isAllDay flag
            // If times contains "allday", return true
            return times?.contains("allday") ?? false
        }
        set {
            // Store the isAllDay flag in the 'times' property
            // This is a temporary solution until the Core Data model is updated
            times = newValue ? "allday" : ""
        }
    }
}
