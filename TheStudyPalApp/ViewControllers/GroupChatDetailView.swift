//
//  GroupChatDetailView.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/11/25.
//
import SwiftUI

struct GroupChatDetailView: View {
    var groupChat: GroupChatInfo
    
    var body: some View {
        VStack {
            Text("Group Chat: \(groupChat.name ?? "Unknown")")
                .font(.title)
                .padding()

            Text("Recent Message: \(groupChat.recentMessage ?? "No messages yet!")")
                .font(.body)
                .padding()

            // Add more UI components for the chat here
        }
        .navigationBarTitle("Chat Details", displayMode: .inline) // Set navigation title here
    }
}

#Preview {
    GroupChatDetailView(groupChat: GroupChatInfo(name: "Group Name", members: []))
}
