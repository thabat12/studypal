//
//  TaskDataModel.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

import Foundation

struct TaskDataModel: Identifiable {
    var id: UUID = .init()
    let taskName: String
    let taskType: String
    var taskIsFinished: Bool
}
