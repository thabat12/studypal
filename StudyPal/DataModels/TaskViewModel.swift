import Foundation
import SwiftUI
import CoreData

// MARK: - TaskViewModel
class TaskViewModel: ObservableObject {
    @Published var tasks: [StudyPalTask] = []
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let taskService = TaskService.shared
    
    init() {
        loadTasks()
        loadCategories()
    }
    
    // MARK: - Load Tasks
    func loadTasks() {
        Task { @MainActor in
            isLoading = true
            
            do {
                let fetchedTasks = try await taskService.getTasks()
                self.tasks = fetchedTasks
                self.isLoading = false
                self.errorMessage = nil
            } catch {
                self.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Load Categories
    func loadCategories() {
        Task { @MainActor in
            do {
                let fetchedCategories = try await taskService.getCategories()
                self.categories = fetchedCategories
            } catch {
                print("Failed to load categories: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Create Task
    func createTask(name: String, 
                   description: String? = nil,
                   dueDate: Date? = nil,
                   isAllDay: Bool = false,
                   categoryName: String? = nil,
                   categoryColor: String? = nil,
                   hasGroup: Bool = false) async -> Bool {
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let _ = try await taskService.createTask(
                name: name,
                description: description,
                dueDate: dueDate,
                isAllDay: isAllDay,
                categoryName: categoryName,
                categoryColor: categoryColor,
                hasGroup: hasGroup
            )
            
            await MainActor.run {
                isLoading = false
            }
            
            loadTasks()
            return true
        } catch {
            await MainActor.run {
                errorMessage = "Failed to create task: \(error.localizedDescription)"
                isLoading = false
            }
            return false
        }
    }
    
    // MARK: - Toggle Task Completion
    func toggleTaskCompletion(taskId: String, completed: Bool) {
        Task {
            do {
                print("Toggling task \(taskId) to completion state: \(completed)")
                
                // Update UI immediately for a more responsive feel
                await MainActor.run {
                    if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                        tasks[index].completed = completed
                        tasks[index].completionDate = completed ? Date() : nil
                        objectWillChange.send()
                    }
                }
                
                // Then update backend
                let _ = try await taskService.updateTask(
                    taskId: taskId,
                    completed: completed,
                    completionDate: completed ? Date() : nil
                )
                
                // Reload all tasks to ensure consistency
                await MainActor.run {
                    loadTasks()
                }
            } catch {
                // Revert UI if backend update fails
                await MainActor.run {
                    if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                        tasks[index].completed = !completed
                        tasks[index].completionDate = !completed ? Date() : nil
                        objectWillChange.send()
                    }
                    errorMessage = "Failed to update task completion: \(error.localizedDescription)"
                    print("Error toggling task completion: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(taskId: String) async -> Bool {
        do {
            let success = try await taskService.deleteTask(taskId: taskId)
            
            if success {
                await MainActor.run {
                    // Remove from local array if exists
                    if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                        tasks.remove(at: index)
                        objectWillChange.send()
                    }
                }
                
                // Refresh the tasks to ensure consistency
                loadTasks()
                return true
            }
            return false
        } catch {
            await MainActor.run {
                errorMessage = "Failed to delete task: \(error.localizedDescription)"
                print("Error deleting task: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Category Helpers
    func convertToCategoryUIModels() -> [CategoryUIModel] {
        return categories.map { category in
            CategoryUIModel(
                name: category.name ?? "Unknown",
                color: colorFromString(category.color ?? "blue"),
                selected: false
            )
        }
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        default: return .blue
        }
    }
} 