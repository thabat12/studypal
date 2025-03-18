//
//  NoteDataModels.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

import Foundation

struct NoteDataModel: Identifiable {
    let id: UUID = .init()
    let name: String
    let date: String
}
