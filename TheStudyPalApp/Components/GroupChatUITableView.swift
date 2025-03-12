//
//  GroupChatUITableView.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/11/25.
//
import SwiftUI

// Define a simple model for the chat message
class GroupChatViewModel: ObservableObject {
    @Published var groupChats: [GroupChatInfo] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    @MainActor
    func getAllGroupChats() async {
        print("get all group chats is called now")
        self.isLoading = true
        do {
            let groupChats = try await StudyPalAPI.getAllUserGroupChats()
            self.groupChats = groupChats
            self.errorMessage = nil
            print("so we got the group chats now")
        } catch FirebaseAPIErrors.errorParsingFirestoreDocument {
            self.errorMessage = "Internal app error"
            print("error1")
        } catch FirebaseAPIErrors.userNotSignedIn {
            self.errorMessage = "User not signed in"
            print("error2")
        } catch let error {
            self.errorMessage = "Unknown error: \(error)"
            print("error3")
        }
        
        self.isLoading = false
        
    }
}

struct GroupChatUITableView: View {
    @StateObject private var viewModel = GroupChatViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .padding()
                } else {
                    List(viewModel.groupChats) { groupChat in
                        NavigationLink(destination: GroupChatDetailView(groupChat: groupChat)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(groupChat.name!)
                                        .font(.title2)
                                    
                                    Text(groupChat.recentMessage ?? "Nothing here yet!")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        
                                        
                                }
                                
                                Spacer()
                            }
                        }
                        
                    }
                }
                
            }
            .onAppear {
                Task {
                    await viewModel.getAllGroupChats()
                }
            }
        }
    }
}


#Preview {
    GroupChatUITableView()
}
