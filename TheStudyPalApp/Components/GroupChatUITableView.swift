//
//  GroupChatUITableView.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/11/25.
//
import SwiftUI

// Define a simple model for the chat message
struct GroupChatInfo: Identifiable {
    var id = UUID()
    var name: String
    var recentMessage: String
}


struct GroupChatUITableView: View {
    
    // Sample data
    var messages = [
        GroupChatInfo(name: "Group 1", recentMessage: "Hey guys"),
        GroupChatInfo(name: "Group 2", recentMessage: "This is from another group"),
        GroupChatInfo(name: "Group 3", recentMessage: "This is from the third group")
    ]
    
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
            
            List(messages) { message in
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(message.name)
                            .font(.title2)
                        
                        Text(message.recentMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                            
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Group Chat")
            .background(Color.red)
        }
    }
}


#Preview {
    GroupChatUITableView()
}

//struct GroupChatUITableView: View {
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("hi there")
//                    .font(.headline)
//                Text("another cell here")
//                    .font(.headline)
//            }
//            
//            Spacer()
//        }
//    }
//}
//
//
//#Preview {
//    GroupChatUITableView()
//}
