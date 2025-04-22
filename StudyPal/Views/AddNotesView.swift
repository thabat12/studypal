//
//  AddNotesView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 4/21/25.
//

import SwiftUI

enum NotesInfoModelErrors: Error {
    case missingFields
    case incorrectTimeFormat
}

struct NotesInfoModel: Identifiable {
    let id: String
    let modifiedTime: Date
    let name: String
    let thumbnailLink: String?

    init(dict: [String: Any]) throws {
        guard
            let id = dict["id"] as? String,
            let modifiedTimeStr = dict["modifiedTime"] as? String,
            let name = dict["name"] as? String
        else {
            throw NotesInfoModelErrors.missingFields
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC") // Ensure the formatter uses UTC
        guard let modifiedTime = formatter.date(from: modifiedTimeStr) else {
            throw NotesInfoModelErrors.incorrectTimeFormat
        }

        self.id = id
        self.modifiedTime = modifiedTime
        self.name = name
        self.thumbnailLink = dict["thumbnailLink"] as? String
    }
}

// https://developer.apple.com/documentation/swiftui/picker
enum NotesSource: String, CaseIterable, Identifiable {
    case everything, files
    case googleDocs = "Google Docs"
    var id: Self { self } // TODO: figure
}

struct AddNotesView: View {
    @State private var selectedNotesSource: NotesSource = .everything
    @State private var googleDocsNotes: [NotesInfoModel]?
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Select a document to generate automatic summarizations & flashcards")
                .padding(.horizontal, 10)
                
            Picker("NotesSource", selection: $selectedNotesSource) {
                ForEach(NotesSource.allCases) { notesSource in
                    Text(notesSource.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: .infinity)
            .padding()
            
            Divider()
            
            Spacer()
        }
        .onAppear {
            Task {
                
                StudyPalAPI.getGoogleDocsDocuments {
                    documents in
                    
                    guard let documents = documents else { return }
                    
                    guard let files: [[String: Any]] = documents["files"] as? [[String: Any]] else {
                        return
                    }
                    
                    // Mapping each file dictionary to a NotesInfoModel
                    self.googleDocsNotes = files.compactMap { fileDict in
                        
                        do {
                            let model = try NotesInfoModel(dict: fileDict)
                            return model
                        } catch {
                            return nil
                        }
                    }
                    
                    print(self.googleDocsNotes ?? "wut")
                }
            }
        }
    }
}

#Preview {
    AddNotesView()
}
