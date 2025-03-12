//
//  JoinGroupView.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/12/25.
//

import SwiftUI
import UIKit

struct JoinGroupView: View {
    @State private var groupSearchName: String = ""
    @State private var loading = true
    @State private var joinableGroups: [GroupChatInfo] = []
    
    var joinGroupAction: (String, String) -> Void
    
    let searchBarCutoff = 150.0
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            if (loading) {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(joinableGroups) { group in
                            GroupChatJoinableUITableCell(gcInfo: group, action: joinGroupAction)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, searchBarCutoff + 20)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 100)
                }
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    ZStack {
                        TextField("Search Group", text: $groupSearchName)
                            .foregroundColor(.black) // Text color
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .cornerRadius(5) // Rounded corners for the text field
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 30)

                }
                .frame(height: searchBarCutoff)
                .padding(5)
                .background(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all) // Ensure the entire view is within the safe area
        .contentShape(Rectangle())
        .onAppear {
            Task {
                do {
                    joinableGroups = try await StudyPalAPI.getAllGroupChats()
                    
                    loading = false
                } catch FirebaseAPIErrors.errorParsingFirestoreDocument {
                    print("error in parsing firestore document")
                } catch FirebaseAPIErrors.userNotSignedIn {
                    print("the user is not signed in for some reason")
                }
            }
        }
    }

}

#Preview {
    JoinGroupView(joinGroupAction: {
        _, _ in
    })
}
