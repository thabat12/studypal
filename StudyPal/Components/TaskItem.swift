//
//  TaskItem.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

import SwiftUI

enum CheckMarkStates: String {
    case unchecked = "checkmark.circle"
    case checked = "checkmark.circle.fill"
}

struct TaskItem: View {
    
    // Arguments for TaskItem
    public var taskName: String
    public var taskGroup: String = "ios group"
    public var taskType: String
    @Binding var taskCompleted: Bool
    var onTaskTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                // Checkbox with its own tap area
                Button(action: {
                    // Toggle the task completion state
                    taskCompleted.toggle()
                }) {
                    Image(systemName: taskCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25, alignment: .top)
                        .foregroundColor(taskCompleted ? .green : .accentColor)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                // The title stuff - this area is tappable for editing
                VStack(alignment: .leading) {
                    Text(taskName)
                        .fontWeight(.semibold)
                        .strikethrough(taskCompleted)
                        .foregroundColor(taskCompleted ? .gray : .primary)
                    Text(taskGroup)
                        .foregroundColor(taskCompleted ? .gray : .primary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let onTaskTap = onTaskTap {
                        onTaskTap()
                    }
                }
                
                Spacer()
                
                Text(taskType)
                    .font(.system(size: 15))
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var taskCompleted: Bool = false
    TaskItem(
        taskName: "Task Name", 
        taskType: "Group Activity", 
        taskCompleted: $taskCompleted,
        onTaskTap: { print("Task tapped for editing") }
    )
}
