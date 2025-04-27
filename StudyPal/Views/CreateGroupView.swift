//
//  CreateGroupView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/30/25.
//

import SwiftUI
import PhotosUI

enum CreateGroupFocusField: Hashable {
    case groupName, groupDesc, done
}

struct CreateGroupView: View {
    
    @State var selectedItem: PhotosPickerItem?
    @State var imageData: Data?
    
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
            
            ZStack {
                if let imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                }
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Select Image")
            }
            
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
            
            Spacer()
            
            HStack {
                Button(action: {
                    appState.showTab = true
                    
                    Task {
                        do {
                            let res = try await StudyPalAPI.createGroupChat(groupChatName: groupNameField, groupDescription: descriptionField, privacySetting: selectedPrivacy == 1, groupImage: (imageData != nil) ? UIImage(data: imageData!): nil)
                            
                            
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
        .onChange(of: selectedItem) { oldItem, newItem in
            
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
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
        .environmentObject(AppState())
}
