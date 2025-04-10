import Foundation
import CoreData
import FirebaseAuth

// MARK: - TaskServiceError
enum TaskServiceError: Error {
    case saveFailed
    case fetchFailed
    case userNotFound
    case categoryNotFound
    case taskNotFound
    case updateFailed
    case deleteFailed
}

// MARK: - TaskService
class TaskService {
    static let shared = TaskService()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        self.viewContext = CoreDataStack.shared.persistentContainer.viewContext
    }
    
    // MARK: - Create Task
    func createTask(name: String, 
                   description: String? = nil,
                   dueDate: Date? = nil,
                   isAllDay: Bool = false,
                   categoryName: String? = nil,
                   categoryColor: String? = nil,
                   hasGroup: Bool = false) async throws -> StudyPalTask {
        
        // Get current user ID
        let userId = Auth.auth().currentUser?.uid ?? "unknown"
        
        // Create a task object
        let task = StudyPalTask(context: viewContext)
        task.id = UUID().uuidString
        task.name = name
        task.taskDesc = description
        task.dueDate = dueDate
        task.createdBy = userId
        task.completed = false
        task.isAllDay = isAllDay
        
        // Handle category if specified
        if let categoryName = categoryName, !categoryName.isEmpty {
            let category = try await getOrCreateCategory(name: categoryName, color: categoryColor ?? "blue")
            task.category = category
        }
        
        // Logic for group relationship would go here if hasGroup is true
        if hasGroup {
            // TODO: Add group relationship logic when implemented
        }
        
        // Save changes
        do {
            try viewContext.save()
            return task
        } catch {
            print("Error saving task: \(error)")
            throw TaskServiceError.saveFailed
        }
    }
    
    // MARK: - Get or Create Category
    private func getOrCreateCategory(name: String, color: String) async throws -> Category {
        // Try to fetch an existing category with this name
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let existingCategory = results.first {
                return existingCategory
            } else {
                // Create a new category
                let category = Category(context: viewContext)
                category.id = UUID().uuidString
                category.name = name
                category.color = color
                
                try viewContext.save()
                return category
            }
        } catch {
            print("Error fetching or creating category: \(error)")
            throw TaskServiceError.categoryNotFound
        }
    }
    
    // MARK: - Get Tasks
    func getTasks(completed: Bool? = nil) async throws -> [StudyPalTask] {
        let userId = Auth.auth().currentUser?.uid
        
        let fetchRequest: NSFetchRequest<StudyPalTask> = StudyPalTask.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        // Add predicate for user
        if let userId = userId {
            predicates.append(NSPredicate(format: "createdBy == %@", userId))
        }
        
        // Add predicate for completion status if specified
        if let completed = completed {
            predicates.append(NSPredicate(format: "completed == %@", NSNumber(value: completed)))
        }
        
        // Combine predicates if we have any
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // Sort by due date (most recent first)
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let tasks = try viewContext.fetch(fetchRequest)
            return tasks
        } catch {
            print("Error fetching tasks: \(error)")
            throw TaskServiceError.fetchFailed
        }
    }
    
    // MARK: - Update Task
    func updateTask(taskId: String, 
                   name: String? = nil,
                   description: String? = nil,
                   dueDate: Date? = nil,
                   isAllDay: Bool? = nil,
                   completed: Bool? = nil,
                   completionDate: Date? = nil,
                   completionNotes: String? = nil,
                   categoryName: String? = nil,
                   categoryColor: String? = nil) async throws -> StudyPalTask {
        
        // Fetch the task
        let fetchRequest: NSFetchRequest<StudyPalTask> = StudyPalTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskId)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            guard let task = results.first else {
                throw TaskServiceError.taskNotFound
            }
            
            // Update task properties
            if let name = name {
                task.name = name
            }
            
            if let description = description {
                task.taskDesc = description
            }
            
            if let dueDate = dueDate {
                task.dueDate = dueDate
            }
            
            if let isAllDay = isAllDay {
                task.isAllDay = isAllDay
            }
            
            if let completed = completed {
                task.completed = completed
                
                // If task is being completed, set completion date
                if completed && task.completionDate == nil {
                    task.completionDate = Date()
                }
            }
            
            if let completionDate = completionDate {
                task.completionDate = completionDate
            }
            
            if let completionNotes = completionNotes {
                task.completionNotes = completionNotes
            }
            
            // Update category if specified
            if let categoryName = categoryName, !categoryName.isEmpty {
                let category = try await getOrCreateCategory(name: categoryName, color: categoryColor ?? "blue")
                task.category = category
            }
            
            // Save changes
            try viewContext.save()
            return task
            
        } catch {
            print("Error updating task: \(error)")
            throw TaskServiceError.updateFailed
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(taskId: String) async throws -> Bool {
        let fetchRequest: NSFetchRequest<StudyPalTask> = StudyPalTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskId)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            guard let task = results.first else {
                throw TaskServiceError.taskNotFound
            }
            
            viewContext.delete(task)
            try viewContext.save()
            return true
        } catch {
            print("Error deleting task: \(error)")
            throw TaskServiceError.deleteFailed
        }
    }
    
    // MARK: - Get Categories
    func getCategories() async throws -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let categories = try viewContext.fetch(fetchRequest)
            return categories
        } catch {
            print("Error fetching categories: \(error)")
            throw TaskServiceError.fetchFailed
        }
    }
} 