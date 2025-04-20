//
//  GroupTile.swift
//  StudyPal
//
//  Created by Abhi Bichal on 4/20/25.
//

import SwiftUI

struct GroupChatLabelTileComponent: View {
    var groupChat: GroupChatInfoModel
    
    var body: some View {
        HStack(spacing: 15) {
            if (groupChat.imageURL != nil) {
                AsyncImage(url: URL(string: groupChat.imageURL!)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    } else if phase.error != nil {
                        Text("Failed to load image!")
                    } else {
                        ProgressView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            
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
}

struct DraggableOverlayGroupChatView: View {
    
    var groupChat: GroupChatInfoModel
    @Binding var toggleBounce: Bool
    
    private let swipeThreshold: CGFloat = -100
    
    @State private var offset: CGFloat = 0
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationLink {
            GroupChatView(groupChatId: groupChat.id)
        } label: {
            GroupChatLabelTileComponent(groupChat: groupChat)
        }
        .contentShape(Rectangle())
        .offset(x: self.offset)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    
                    if value.translation.width < 0 {
                        self.offset = max(value.translation.width, self.swipeThreshold)
                        
                        if self.offset == self.swipeThreshold && toggleBounce == false {
                            // toggle
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                toggleBounce = true
                            }
                        }
                    }
                }
                .onEnded { value in
                    if self.offset <= swipeThreshold {
                        self.offset = self.swipeThreshold
                        self.showAlert = true
                        
                    } else {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            self.offset = 0
                            toggleBounce = false
                        }
                    }
                }
        )
        .alert("Are you sure you want to leave this group chat?", isPresented: $showAlert) {
            SwiftUI.Button("Leave", role: .destructive) {
                // You can call your deletion logic here
                
                Task {
                    do {
                        let res = try await StudyPalAPI.leaveGroupChat(groupChatId: groupChat.id)
                        
                        if !res {
                            print("unable to leave the group chat!")
                        }
                    } catch {
                        print("something wrong happened")
                    }
                    
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        self.offset = 0
                        toggleBounce = false
                    }
                }
            }
            SwiftUI.Button("Cancel", role: .cancel) {
                
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    self.offset = 0
                    toggleBounce = false
                }
            }
        }
    }
}

struct GroupTile: View {
    var groupChat: GroupChatInfoModel
    
    @State var toggleBounce = false
    
    var body: some View {
        
        ZStack {
            
            HStack(alignment: .center) {
                Spacer()
                Image(systemName: "trash.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.red)
                    .scaleEffect(toggleBounce ? 1 : 0)
            }
            .padding()
            
            DraggableOverlayGroupChatView(groupChat: groupChat, toggleBounce: $toggleBounce)
        }
    }
}

#Preview {
    if let groupChatInfo = try? GroupChatInfoModel(dictionary: [
        "name": "Group Name",
        "isPrivate": "false",
        "members": ["a", "b", "c"],
        "id": "12345",
        "imageURL": "https://www.explore.com/img/gallery/the-50-most-incredible-landscapes-in-the-whole-entire-world/l-intro-1672072042.jpg"
    ]) {
        return GroupTile(groupChat: groupChatInfo)
    } else {
        return Text("Failed to create preview")
    }
}
