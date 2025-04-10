//
//  CreateGroupView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/30/25.
//

import SwiftUI

enum CreateGroupFocusField: Hashable {
    case groupName, groupDesc, done
}

struct CreateGroupView: View {
    
    @State var groupNameField: String = ""
    @State var descriptionField: String = ""
    @FocusState private var groupFieldFocused: CreateGroupFocusField?
    @State private var selectedCourse = 0
    @State private var selectedPrivacy = 0
    @EnvironmentObject private var appState: AppState
    
    
    @State var groupChatCreationError = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 15) {
            TextField("Group Name", text: $groupNameField)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.6), lineWidth: 2)
                )
                .focused($groupFieldFocused, equals: .groupName)
                .onSubmit {
                    groupFieldFocused = CreateGroupFocusField.groupDesc
                }
            
            List {
                Picker("Select Course", selection: $selectedCourse) {
                    Text("Course 1").tag(0)
                    Text("Course 2").tag(1)
                    Text("Course 3").tag(2)
                }
            }
            .frame(height: 100)
           
            TextField("Description", text: $descriptionField)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.6), lineWidth: 2)
                )
                .focused($groupFieldFocused, equals: .groupDesc)
                .onSubmit {
                    groupFieldFocused = CreateGroupFocusField.done
                }
            
            HStack {
                Text("Privacy Setting")
                
                Picker("Privacy Setting", selection: $selectedPrivacy) {
                    Text("ON").tag(0)
                    Text("OFF").tag(1)
                }
                .pickerStyle(.segmented)
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    appState.showTab = true
                    
                    Task {
                        do {
                            let res = try await StudyPalAPI.createGroupChat(groupChatName: groupNameField, groupDescription: descriptionField, privacySetting: selectedPrivacy == 1)
                            
                            
                            if !res {
                                self.groupChatCreationError = true
                            } else {
                                dismiss()
                            }
                        } catch {
                            self.groupChatCreationError = true
                        }
                        
                    }
                }) {
                    
                    Text("Create Group")
                        .padding()
                }
            }
            .frame(maxHeight: 100)
            
            
            
        }
        .padding(15)
        .contentShape(Rectangle())
        .alert(
            "Error Creating Group Chat!",
            isPresented: $groupChatCreationError) {
            
                SwiftUI.Button() {
                    self.groupChatCreationError = false
                } label: {
                    Text("OK")
                }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if groupFieldFocused != .done {
                        groupFieldFocused = .done
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
        )
        .onAppear {
            appState.showTab = false
            groupFieldFocused = .groupName
        }
    }
}

#Preview {
    CreateGroupView()
}
