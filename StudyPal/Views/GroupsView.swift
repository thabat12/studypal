//
//  GroupsView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/15/25.
//

import SwiftUI

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
    
    init(dictionary: [String: Any]) throws {
        
        self.name = dictionary["name"] as? String
        self.isPrivate = dictionary["isPrivate"] as? Bool
        self.members = dictionary["members"] as? [String]
        self.recentMessage = dictionary["recentMessage"] as? String
        
        // the id is the only thing i need for the UI to work properly
        guard let uuidString = dictionary["id"] as? String else { throw GroupChatDataModelErrors.failedToParseDocument }
        self.id = uuidString
    }
}


/*
 The GroupChatViewModel communicates with the "StudyPal API" to gather all the active groups chats that the user is in.
 
    It is an observable object, and that means that it will be treated as a State variable for the GroupsView model. Whenever the Published variables are changed within the GroupChatViewModel, the UI will get notified of that change and will re-render.
 */
class GroupChatViewModel: ObservableObject {
    @Published var groupChats: [GroupChatInfoModel] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    init () {
        print("this got initialized...")
    }
    /*
     The actual updates to the @Published variables will happen on the main thread because that is where SwiftUI actually does UI updates. If you did this on a background thread, the main thread may never get notified of UI changes and these changes may not actually reflect on the screen.
    */
    @MainActor
    func getAllGroupChats() async {
        self.isLoading = true
        do {
            let groupChats = try await StudyPalAPI.getAllUserGroupChats()
            self.groupChats = groupChats.map {
                groupChatDict in
                do {
                    let res = try GroupChatInfoModel(dictionary: groupChatDict)
                    return res
                } catch {
                    return GroupChatInfoModel(name: "error")
                }

            }
            self.errorMessage = nil
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
    
    #if targetEnvironment(simulator)
    @MainActor
    func mockGetAllGroupChats() {
        self.groupChats = [
            GroupChatInfoModel(name: "Group 1", isPrivate: true, members: ["rohan", "abhinav", "tejas"], recentMessage: "recent message 1"),
            GroupChatInfoModel(name: "Group 2", isPrivate: true, members: ["rohan", "abhinav", "tejas"], recentMessage: "recent message 2"),
            GroupChatInfoModel(name: "Group 3", isPrivate: true, members: ["rohan", "abhinav", "tejas"], recentMessage: "recent message 3"),
            GroupChatInfoModel(name: "Group 4", isPrivate: true, members: ["rohan", "abhinav", "tejas"], recentMessage: "recent message 4")
        ]
        self.errorMessage = nil
        self.isLoading = false
    }
    #endif
}



struct GroupsView: View {
    
    @StateObject private var viewModel = GroupChatViewModel()
    @State private var expandedBinding: Bool = false
    @EnvironmentObject private var appState: AppState
    
    @State private var navPath = NavigationPath()
    
    var body: some View {
        ZStack(alignment: .center) {
            if false {
                Text("so this should never appear here!")
            }
            else if viewModel.isLoading == true {
                ProgressView("Loading... and value is \(viewModel.isLoading)")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .padding()
                    .foregroundStyle(Color.red)
            } else {
                
                ScrollView {
                    VStack {
                        ForEach(viewModel.groupChats) {
                            groupChat in
                            
                            NavigationLink {
                                GroupChatView(groupChatId: groupChat.id)
                            } label: {
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
                                .padding()
                                .contentShape(Rectangle())
                            }
                            .contentShape(Rectangle())
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.6))
                    )
                    .padding(.horizontal, 20)
                }
                
                // TODO: Why is this not working??
//                List(viewModel.groupChats) { groupChat in
//                    NavigationLink {
//                        GroupChatView(groupChatId: groupChat.id)
//                    } label: {
//                        HStack {
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text(groupChat.name!)
//                                    .font(.title2)
//                                
//                                Text(groupChat.recentMessage ?? "Nothing here yet!")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//                            
//                            Spacer()
//                        }
//                    }
//                    .contentShape(Rectangle())
//                }
                
                ZStack(alignment: .bottomTrailing) {
                    Color.clear
                    
                    AddButtonSheet(padding: 15, expandedBinding: $expandedBinding) {
                        VStack(alignment: .center) {
                            NavigationLink {
                                CreateGroupView()
                            } label: {
                                Text("Create Group")
                                    .foregroundStyle(Color.white)
                                    .padding(.vertical, 5)
                            }
                            
                            Divider()
                            Text("Join Group")
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 5)
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(maxWidth: 250)
                    .safeAreaPadding(.bottom, 90)
                    .safeAreaPadding(.trailing, 30)
                    
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged {_ in
                    expandedBinding.toggle()
                }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            self.appState.showTab = true
            
            #if targetEnvironment(simulator)
            viewModel.mockGetAllGroupChats()
            #else
            Task {
                await viewModel.getAllGroupChats()
            }
            #endif
        }
    }
}

#Preview {
    GroupsView()
}
