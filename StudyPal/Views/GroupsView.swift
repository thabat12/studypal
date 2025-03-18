//
//  GroupsView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/15/25.
//

import SwiftUI

/*
 The GroupChatViewModel communicates with the "StudyPal API" to gather all the active groups chats that the user is in.
 
    It is an observable object, and that means that it will be treated as a State variable for the GroupsView model. Whenever the Published variables are changed within the GroupChatViewModel, the UI will get notified of that change and will re-render.
 */
class GroupChatViewModel: ObservableObject {
    @Published var groupChats: [GroupChatInfoModel] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    /*
     The actual updates to the @Published variables will happen on the main thread because that is where SwiftUI actually does UI updates. If you did this on a background thread, the main thread may never get notified of UI changes and these changes may not actually reflect on the screen.
    */
    @MainActor
    func getAllGroupChats() async {
        self.isLoading = true
        do {
            let groupChats = try await StudyPalAPI.getAllUserGroupChats()
            self.groupChats = groupChats
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
}


struct GroupsView: View {
    
    @ObservedObject private var viewModel = GroupChatViewModel()
    
    var body: some View {
        ZStack(alignment: .center) {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .padding()
                    .foregroundStyle(Color.red)
            } else {
                List(viewModel.groupChats) { groupChat in
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
                    .onTapGesture {
                        print("pressed")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                await viewModel.getAllGroupChats()
            }
        }
    }
}

#Preview {
    GroupsView()
}
