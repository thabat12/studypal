//
//  GroupChatDataModel.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

/*
 This file will contain everything that is group chat related for data models. This includes:
    - Group chat info model
    - Group chat message model
 */

import Foundation
import FirebaseCore

enum GroupChatDataModelErrors: Error {
    case failedToParseDocument
}

struct GroupChatInfoModel: Identifiable {
    let id: String
    let name: String?
    let isPrivate: Bool?
    let members: [String]?
    let recentMessage: String?
    
    init(name: String? = nil,
        isPrivate: Bool? = nil,
        members: [String]? = nil,
        recentMessage: String? = nil) {
        
        self.name = name
        self.isPrivate = isPrivate
        self.members = members
        self.recentMessage = recentMessage
        
        self.id = UUID().uuidString // helps with firebase compatibility
    }
    
    init?(dictionary: [String: Any]) throws {
        
        self.name = dictionary["name"] as? String
        self.isPrivate = dictionary["isPrivate"] as? Bool
        self.members = dictionary["members"] as? [String]
        self.recentMessage = dictionary["recentMessage"] as? String
        
        // the id is the only thing i need for the UI to work properly
        guard let uuidString = dictionary["id"] as? String else { throw GroupChatDataModelErrors.failedToParseDocument }
        self.id = uuidString
    }
}

struct GroupChatMessageModel: Identifiable {
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
        
        // Key assumption: Firebase provides the document IDs that you can use
        guard let id = document["id"] as? String else { throw GroupChatDataModelErrors.failedToParseDocument }
        self.id = id
    }
}

