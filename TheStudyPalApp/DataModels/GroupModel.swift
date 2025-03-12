//
//  GroupModel.swift
//  Project-GroupScreen
//
//  Created by Abhi Bichal on 3/9/25.
//

import Foundation

/*
 
    What is the group model?
    
 
 */

enum GroupModelErrors: Error {
    case failedToParseDocument
}

struct GroupChatMember: Codable {
    let name: String
    let profileSrc: String?
}

struct Group: Codable {
    let name: String
    let members: [GroupChatMember]
}

struct GroupChatInfo: Identifiable {
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
        guard let uuidString = dictionary["id"] as? String else { throw GroupModelErrors.failedToParseDocument }
        self.id = uuidString
    }
}
