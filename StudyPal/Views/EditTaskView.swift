//
//  EditTaskView.swift
//  StudyPal
//
//  Created by StudyPal on 4/15/25.
//

import SwiftUI
import CoreData

struct EditTaskView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath = NavigationPath()
    @State private var taskName: String
    @State private var taskDesc: String
    @State private var taskCategoryNew = ""
    @State private var selectedDate: Date
    @State private var isAllDay: Bool
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    @State private var selectedCategory: String?
    @State private var showDeleteConfirmation = false
    @FocusState private var focused: FormFieldFocus?
    
    let task: StudyPalTask
    private let taskViewModel: TaskViewModel
    
    // Categories from Core Data
    @State private var categories: [CategoryUIModel] = []
    
    init(task: StudyPalTask, taskViewModel: TaskViewModel) {
        self.task = task
        self.taskViewModel = taskViewModel
        
        // Initialize state with task values
        _taskName = State(initialValue: task.name ?? "")
        _taskDesc = State(initialValue: task.taskDesc ?? "")
        _selectedDate = State(initialValue: task.dueDate ?? Date())
        _isAllDay = State(initialValue: task.isAllDay)
        _selectedCategory = State(initialValue: task.category?.name)
    }
    
    var body: some View {
        ScrollView {
            VStack() {
                Text("Task")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                
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
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer(minLength: 70)
                
                HStack(alignment: .top, spacing: 20) {
                    Button(action: {
                        updateTask()
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
                    
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Delete")
                            .padding()
                            .foregroundColor(.white)
                    }
                    .background(Color.red)
                    .cornerRadius(8)
                    .disabled(isSaving)
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Task")
                    .font(.headline)
            }
        }
        .confirmationDialog(
            "Delete Task",
            isPresented: $showDeleteConfirmation
        ) {
            SwiftUI.Button("Delete", role: .destructive) {
                if let id = task.id {
                    deleteTask(id: id)
                }
            }
            SwiftUI.Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
        .onAppear {
            focused = FormFieldFocus.taskName
            appState.showTab = false
            categories = taskViewModel.convertToCategoryUIModels()
            
            // Pre-select the current category if it exists
            if let categoryName = task.category?.name {
                selectedCategory = categoryName
            }
        }
        .onDisappear {
            appState.showTab = true
        }
    }
    
    private func updateTask() {
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
            do {
                if let taskId = task.id {
                    let _ = try await TaskService.shared.updateTask(
                        taskId: taskId,
                        name: taskName,
                        description: taskDesc.isEmpty ? nil : taskDesc,
                        dueDate: selectedDate,
                        isAllDay: isAllDay,
                        categoryName: finalCategoryName
                    )
                    
                    // Reload tasks after update
                    taskViewModel.loadTasks()
                    
                    await MainActor.run {
                        isSaving = false
                        dismiss()
                    }
                } else {
                    await MainActor.run {
                        isSaving = false
                        errorMessage = "Cannot update task: Missing task ID"
                    }
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Failed to update task: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteTask(id: String) {
        isSaving = true
        
        Task {
            let success = await taskViewModel.deleteTask(taskId: id)
            
            await MainActor.run {
                isSaving = false
                if success {
                    dismiss()
                } else {
                    errorMessage = "Failed to delete task. Please try again."
                }
            }
        }
    }
}

// Simple mock preview that avoids CoreData initialization
#Preview {
    Text("EditTaskView Preview - Unable to initialize CoreData in preview")
        .padding()
} 