//
//  GroupChatJoinableUITableCell.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/12/25.
//
import SwiftUI

struct GroupChatJoinableUITableCell: View {
    @State private var isPressed = false
    
    let gcInfo: GroupChatInfo
    let action: (String, String) -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text(gcInfo.name!)
                    .font(.headline)
                Text("Members: \(gcInfo.members?.count ?? 0)")
                    .font(.caption)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color.gray)
        }
        .contentShape(Rectangle())
        .padding(5)
        .background(isPressed ? Color.gray : Color.white)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.99 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .onTapGesture {
            action(gcInfo.id, gcInfo.name!)
        }
    }
}

#Preview {
    GroupChatJoinableUITableCell(gcInfo: GroupChatInfo(name: "Group Name", members: ["member1", "member2", "member3"]), action: {
        _, _ in
        
    })
}
