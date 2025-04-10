//
//  GroupChatView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 4/7/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

enum TextFieldFocused {
    case unfocused, focused
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
    
    init(document: [String: Any]) {
        self.sender = document["sender"] as? String
        self.message = document["message"] as? String
        self.timestamp = document["timestamp"] as? Timestamp
        
        // Key assumption: Firebase provides the document IDs that you can use
        let id = document["id"] as! String
        self.id = id
    }
}

struct MessageBubble: View {
    
    var message: GroupChatMessageModel
    var isMe: Bool
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {

                Text(message.message!)
                    .padding()
            }
            .frame(maxWidth: 250, maxHeight: 100, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isMe ? Color.blue : Color.gray)
            )
        }
        .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
    }
}

struct GroupChatMessages: View {
    
    let groupChatId: String
    
    @State var myUID: String = ""
    @State var listener: ListenerRegistration? = nil
    
    @State private var messages: [GroupChatMessageModel] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                
                Section {
                    ForEach(messages) {
                        message in
                        
                        MessageBubble(message: message, isMe: message.sender! == myUID)
                    }
                } header: {
                    HStack {
                        Text("Group Chat Name")
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            Task {
                do {
                    myUID = try await StudyPalAPI.getUid()
                    
                    // get all messages
                    let messageData = try await StudyPalAPI.queryGroupChatMessages(groupChatId: self.groupChatId)
                    
                    messages = messageData.map {data in
                        GroupChatMessageModel(document: data)
                    }
                    
                    // listen for any new messages
                    listener = try await StudyPalAPI.groupChatMessagesListener(groupChatId: self.groupChatId, onAddedDocuments: {
                        docChanges in
                        
                        print("there are documents that are added!")
                        var newMessages: [GroupChatMessageModel] = []
                        
                        for documentChange in docChanges {
                            if documentChange.type == .added {
                                let data = documentChange.document.data()
                                newMessages.append(GroupChatMessageModel(document: data))
                            }
                        }
                        
                        self.messages.append(contentsOf: newMessages)
                    })
                    
                } catch {
                    print("error when trying to get the group chats")
                }
            }
            
            
        }
    }
}

struct InputTextField: View {
    
    var groupChatId: String
    
    @FocusState private var focused: Bool
    @State private var text: String = ""
    var body: some View {
            HStack(alignment: .center) {
                TextField("Send Message", text: $text)
                    .focused($focused)
                    .onTapGesture {
                        focused = true
                        print("i am now focused")
                    }
                    .onSubmit {
                        Task {
                            do {
                                try await StudyPalAPI.sendMessageToGroupChat(groupChatId: self.groupChatId, message: text, replyTo: "", attachments: [])
                            } catch {
                                print("some error occurred!")
                            }
                        }
                    }
                    .frame(maxHeight: 30)
                    .padding(.leading, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.6), lineWidth: 3)
                            .fill(Color.gray.opacity(0.3))
                    )
                    .padding(.trailing, 10)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 5)
                            .onEnded {
                                action in
                                
                                let startLoc = action.startLocation
                                let endLoc = action.location
                                
                                let ydist = endLoc.y - startLoc.y
                                _ = endLoc.x - startLoc.x
                                
                                if ydist > 0 {
                                    focused = false
                                }
                            }
                    )
                
                ZStack(alignment: .center) {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 20, maxHeight: 20)
                }
                
                ZStack(alignment: .center) {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 20, maxHeight: 20)
                }
                .onTapGesture {
                    Task {
                        do {
                            try await StudyPalAPI.sendMessageToGroupChat(groupChatId: self.groupChatId, message: self.text, replyTo: "", attachments: [])
                        } catch {
                            print("error sending message!")
                        }
                    }
                }
                
            }
            .padding(.horizontal, 30)
            .onAppear {
                focused = false
            }
    }
}

struct GroupChatView: View {
    
    
    var groupChatId: String
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GroupChatMessages(groupChatId: groupChatId)
            InputTextField(groupChatId: groupChatId)
        }
        .onAppear {
            appState.showTab = false
        }
        .onDisappear {
            appState.showTab = true
        }

    }
}

#Preview {
    GroupChatView(groupChatId: "nothing")
}
