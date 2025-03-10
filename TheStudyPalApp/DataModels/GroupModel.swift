//
//  GroupModel.swift
//  Project-GroupScreen
//
//  Created by Abhi Bichal on 3/9/25.
//

/*
 
    What is the group model?
    
 
 */


enum GroupChatMessageType: Codable {
    case normal
    case sharedNote
}

struct GroupChatMember: Codable {
    let name: String
    let profileSrc: String?
}

struct GroupChatMessage: Codable {
    let from: String
    let message: String
    let type: GroupChatMessageType
}

struct Group: Codable {
    let name: String
    let members: [GroupChatMember]
}
