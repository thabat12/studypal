//
//  GroupChatModel.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/11/25.
//
import Foundation
import FirebaseCore

enum GroupChatModelErrors: Error {
    case failedToParseDocument
}

struct GroupChatMessage: Identifiable {
    let id: String
    let sender: String?
    let message: String?
    let timestamp: Timestamp?
    
    init(sender: String, message: String? = nil, timestamp: Timestamp? = nil) {
        self.sender = sender
        self.message = message
        self.timestamp = timestamp
        self.id = UUID().uuidString
    }
    
    init?(document: [String: Any]) throws {
        self.sender = document["sender"] as? String
        self.message = document["message"] as? String
        self.timestamp = document["timestamp"] as? Timestamp
        // the id is the only thing i really need to enforce here
        guard let id = document["id"] as? String else { throw GroupChatModelErrors.failedToParseDocument }
        self.id = id
    }
}
