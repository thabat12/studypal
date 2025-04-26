//
//  HomeView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/15/25.
//

import SwiftUI
import Foundation

// This can be deleted once the Core Data implementation is complete
struct NoteDataModel: Identifiable {
    let id: UUID = .init()
    let name: String
    let date: String
}

let notesData = [
    ("Note Entry", "2/14/25"),
    ("Note Entry", "2/14/25"),
    ("Note Entry", "2/14/25"),
    ("Note Entry", "2/14/25")
]

struct HomeView: View {
    // Replace hardcoded tasks with TaskViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    
    @State private var allNotes: [NoteDataModel] = notesData.map { note in
        NoteDataModel(name: note.0, date: note.1)
    }
    
    @EnvironmentObject private var appState: AppState
    @State private var selectedTask: TaskFirebaseModel?
    @State private var showEditTask = false
    
    var body: some View {
        ScrollView {
            // Credit: https://medium.com/evangelist-apps/create-a-list-in-swiftui-with-sticky-section-headers-373bab2f9e96
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                
                // MARK: Tasks for Today
                Section {
                    if taskViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if taskViewModel.tasks.isEmpty {
                        Text("No tasks yet. Add one using the + button above.")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .foregroundColor(.gray)
                    } else {
                        ForEach(taskViewModel.tasks) { task in
                            TaskItemView(task: task, taskViewModel: taskViewModel, onTap: {
                                selectedTask = task
                                showEditTask = true
                            })
                                .contentShape(Rectangle())
                        }
                    }
                } header: {
                    
                    // Custom SwiftUI struct
                    HomeHeader {
                        HStack {
                            Text("Tasks for Today")
                                .font(.system(size: 20))
                            Spacer()
                            
                            NavigationLink {
                                AddTaskView()
                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
                
                // MARK: Recent Notes
                Section {
                    ForEach(allNotes) {
                        note in
                        NoteItem(name: note.name, date: note.date)
                    }
                } header: {
                    HomeHeader {
                        HStack {
                            Text("Recent Notes")
                                .font(.system(size: 20))
                            Spacer()
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                // MARK: Quick Actions
                Section {
                    // GeometryReader allows you to access the geometry of parent elements for relationship with the child elements
                    GeometryReader {
                        geometry in
                        
                        VStack(alignment: .center, spacing: 15) {
                            NavigationLink {
                                TimerView()
                            } label: {
                                HStack {
                                    Image(systemName: "timer")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.blue)
                                    
                                    Text("Start Focus Timer")
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .frame(width: geometry.size.width / 7 * 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                            }
                            
                            SwiftUI.Button(action: {}) {
                                Text("Start a Study Session")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(width: geometry.size.width / 7 * 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.primary, lineWidth: 1)
                                    )
                            }
                            
                            SwiftUI.Button(action: {}) {
                                Text("Review my Notes")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(width: geometry.size.width / 7 * 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.primary, lineWidth: 1)
                                    )
                            }
                            
                            SwiftUI.Button(action: {}) {
                                Text("Record Lecture")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(width: geometry.size.width / 7 * 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.primary, lineWidth: 1)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .frame(height: 280) // Fixed height to ensure proper spacing
                } header: {
                    
                    HomeHeader {
                        HStack {
                            Text("Quick Actions")
                                .font(.system(size: 20))
                            Spacer()
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
            }
            .padding(.bottom, 400)
        }
        .refreshable {
            taskViewModel.loadTasks()
        }
        .onAppear {
            taskViewModel.loadTasks()
        }
        .navigationDestination(isPresented: $showEditTask) {
            if let task = selectedTask {
                EditTaskView(task: task, taskViewModel: taskViewModel)
            }
        }
    }
}

// MARK: - TaskItemView
struct TaskItemView: View {
    let task: TaskFirebaseModel
    let taskViewModel: TaskViewModel
    @State private var showConfirmation = false
    var onTap: () -> Void
    
    var body: some View {
        TaskItem(
            taskName: task.name,
            taskType: task.categoryName ?? "No Category",
            taskCompleted: .init(
                get: { task.completed },
                set: { newValue in
                    taskViewModel.toggleTaskCompletion(taskId: task.id, completed: newValue)
                }
            ),
            onTaskTap: onTap
        )
        .id(task.id + (task.completed ? "-completed" : "-uncompleted"))
        .swipeActions {
            SwiftUI.Button(role: .destructive) {
                showConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog("Are you sure you want to delete this task?", isPresented: $showConfirmation) {
            SwiftUI.Button("Delete", role: .destructive) {
                Task {
                    _ = await taskViewModel.deleteTask(taskId: task.id)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

/*
 Just know:
  - HStack, VStack, ZStack
  - modifiers:
    .frame, .padding, .resizable -> .aspectRatio (for images)
  - withAnimation will interpolate any values that are associated with it
 */

