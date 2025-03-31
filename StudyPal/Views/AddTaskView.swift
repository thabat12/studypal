//
//  AddTaskView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/30/25.
//

import SwiftUI


enum FormFieldFocus: Hashable {
    case taskName, description, category, done
}

struct AddTaskView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath = NavigationPath()
    @State private var taskName = ""
    @State private var taskDesc = ""
    @State private var taskCategoryNew = ""
    @State private var selectedTime = Date()
    @State private var selectedDate = Date()
    @State private var isAllDay = false
    @FocusState private var focused: FormFieldFocus?
    
    // This needs to be fetched from CoreData
    @State var categories: [CategoryUIModel] = []
        
    var body: some View {
        VStack() {
            
            TextField("Task Name", text: $taskName)
                .padding()
                .border(Color.black.opacity(0.6), width: 3)
                .focused($focused, equals: .taskName)
                .onSubmit {
                    focused = .description
                }
            
            DropdownMenuDisclosure(title: "Description") {
                TextField("Optional", text: $taskDesc)
                    .padding()
                    .focused($focused, equals: .description)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .onSubmit {
                        focused = .category
                    }
            }
            
            DropdownMenuDisclosure(title: "Category") {
                VStack {
                    ZStack(alignment: .trailing) {
                        TextField("Optional", text: $taskCategoryNew)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.6), lineWidth: 2)
                            )
                            .focused($focused, equals: .category)
                            .onSubmit {
                                focused = .done
                            }
                        
                        RoundedRectangle(cornerRadius: 20)
                            .frame(maxWidth: 40, maxHeight: 40)
                            .padding()
                    }
                    
                    CategoryScrollHorizontal(categories: $categories)
                }
            }
            
            DropdownMenuDisclosure(title: "Times") {
                VStack {
                    DatePicker(
                        "Select a day",
                        selection: $selectedDate,
                        in: Date()...Date().addingTimeInterval(7*24*60*60),
                        displayedComponents: .date
                    )
                    
                    if (!isAllDay) {
                        DatePicker(
                            "Select a time",
                            selection: $selectedDate,
                            displayedComponents: .hourAndMinute
                        )
                    }
                    
                    Toggle("All Day", isOn: $isAllDay)
                        .padding()
                }
                .padding(.top, 10)
            }
            
            DropdownMenuDisclosure(title: "Groups") {
                Text("nothing here for now")
            }
            
            Spacer()
            
            HStack(alignment: .top) {
                Button(action: {
                    print("this is where core data stuff happens")
                    dismiss()
                    appState.showTab = true
                }) {
                    Text("Save Task").padding()
                }
            }
            .frame(maxHeight: 100)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .onAppear {
            focused = FormFieldFocus.taskName
            appState.showTab = false
        }
    }
}

#Preview {
    AddTaskView()
}
