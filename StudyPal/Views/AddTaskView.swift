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
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    @State private var selectedCategory: String? = nil
    @FocusState private var focused: FormFieldFocus?
    
    // Add TaskViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    
    // Categories from Core Data
    @State var categories: [CategoryUIModel] = []
        
    var body: some View {
        ScrollView {
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
                    VStack(spacing: 12) {
                        ZStack(alignment: .trailing) {
                            TextField("Create new category", text: $taskCategoryNew)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black.opacity(0.6), lineWidth: 2)
                                )
                                .focused($focused, equals: .category)
                                .onSubmit {
                                    focused = .done
                                }
                            
                            if !taskCategoryNew.isEmpty {
                                Button(action: {
                                    // Clear new category text
                                    taskCategoryNew = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 12)
                            }
                        }
                        
                        Divider()
                        
                        Text("Or select existing category:")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        CategoryScrollHorizontal(categories: $categories, selectedCategory: $selectedCategory)
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
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer(minLength: 70)
                
                HStack(alignment: .top) {
                    Button(action: {
                        saveTask()
                    }) {
                        if isSaving {
                            ProgressView()
                                .padding()
                        } else {
                            Text("Save Task").padding()
                        }
                    }
                    .disabled(taskName.isEmpty || isSaving)
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxHeight: 100)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focused = FormFieldFocus.taskName
            appState.showTab = false
            categories = taskViewModel.convertToCategoryUIModels()
        }
    }
    
    private func saveTask() {
        guard !taskName.isEmpty else { return }
        
        isSaving = true
        errorMessage = nil
        
        // Determine which category to use
        let finalCategoryName: String?
        if !taskCategoryNew.isEmpty {
            finalCategoryName = taskCategoryNew
        } else {
            finalCategoryName = selectedCategory
        }
        
        Task {
            let success = await taskViewModel.createTask(
                name: taskName,
                description: taskDesc.isEmpty ? nil : taskDesc,
                dueDate: selectedDate,
                isAllDay: isAllDay,
                categoryName: finalCategoryName,
                categoryColor: "blue" // Default color, could be enhanced
            )
            
            await MainActor.run {
                isSaving = false
                
                if success {
                    dismiss()
                    appState.showTab = true
                } else {
                    errorMessage = "Failed to save task. Please try again."
                }
            }
        }
    }
}

#Preview {
    AddTaskView()
}
