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
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                if !taskCompleted {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25, alignment: .top)
                        .opacity(!taskCompleted ? 1 : 0)
                }
                else {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25, alignment: .top)
                        .opacity(taskCompleted ? 1 : 0)
                }
                
                // The title stuff
                VStack(alignment: .leading) {
                    Text(taskName)
                        .fontWeight(.semibold)
                    Text(taskGroup)
                }
                
                Spacer()
                
                Text(taskType)
                    .font(.system(size: 15))
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
        .contentShape(.rect())
        .onTapGesture {
            withAnimation {
                taskCompleted = !taskCompleted
            }
        }
    }
}

#Preview {
    @Previewable @State var taskCompleted: Bool = false
    TaskItem(taskName: "Task Name", taskType: "Group Activity", taskCompleted: $taskCompleted)
}
