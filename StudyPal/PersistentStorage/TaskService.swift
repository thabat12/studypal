import Foundation
import CoreData
import FirebaseAuth
import FirebaseFirestore

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
    
    private let db: Firestore
    
    private init() {
        self.db = Firestore.firestore()
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
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        let taskId = UUID().uuidString
        
        // Prepare the task data
        var taskData: [String: Any] = [
            "id": taskId,
            "name": name,
            "createdBy": userId,
            "completed": false,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        // Add optional fields
        if let description = description {
            taskData["taskDesc"] = description
        }
        
        if let dueDate = dueDate {
            taskData["dueDate"] = dueDate
        }
        
        taskData["isAllDay"] = isAllDay
        
        // Handle category
        if let categoryName = categoryName, !categoryName.isEmpty {
            // First try to find existing category
            let category = try await getOrCreateCategory(name: categoryName, color: categoryColor ?? "blue")
            taskData["categoryId"] = category.id
            taskData["categoryName"] = category.name
            taskData["categoryColor"] = category.color
        }
        
        // Save to Firestore
        do {
            try await db.collection("users").document(userId).collection("tasks").document(taskId).setData(taskData)
            
            // Create a StudyPalTask object for backward compatibility with the UI
            let task = StudyPalTask(context: CoreDataStack.shared.persistentContainer.viewContext)
            task.id = taskId
            task.name = name
            task.taskDesc = description
            task.dueDate = dueDate
            task.createdBy = userId
            task.completed = false
            task.isAllDay = isAllDay
            
            if let categoryName = categoryName, !categoryName.isEmpty {
                let category = Category(context: CoreDataStack.shared.persistentContainer.viewContext)
                category.id = taskData["categoryId"] as? String ?? UUID().uuidString
                category.name = categoryName
                category.color = categoryColor ?? "blue"
                task.category = category
            }
            
            // Don't save to Core Data, just return the object for UI compatibility
            return task
        } catch {
            print("Error saving task to Firestore: \(error)")
            throw TaskServiceError.saveFailed
        }
    }
    
    // MARK: - Get or Create Category
    private func getOrCreateCategory(name: String, color: String) async throws -> (id: String, name: String, color: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        // Try to fetch existing category
        let snapshot = try await db.collection("users").document(userId).collection("categories")
            .whereField("name", isEqualTo: name)
            .getDocuments()
        
        // If category exists, return it
        if let existingCategory = snapshot.documents.first {
            let categoryData = existingCategory.data()
            return (
                id: existingCategory.documentID,
                name: categoryData["name"] as? String ?? name,
                color: categoryData["color"] as? String ?? color
            )
        }
            
        // Create new category
        let categoryId = UUID().uuidString
        let categoryData: [String: Any] = [
            "id": categoryId,
            "name": name,
            "color": color,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(userId).collection("categories").document(categoryId).setData(categoryData)
        
        return (id: categoryId, name: name, color: color)
    }
    
    // MARK: - Get Tasks
    func getTasks(completed: Bool? = nil) async throws -> [StudyPalTask] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        // Create a query for user's tasks
        var query: Query = db.collection("users").document(userId).collection("tasks")
        
        // Add filter for completion status if specified
        if let completed = completed {
            query = query.whereField("completed", isEqualTo: completed)
        }
        
        // Sort by due date
        query = query.order(by: "dueDate", descending: false)
        
        do {
            // Perform the query
            let snapshot = try await query.getDocuments()
            
            // Create context for CoreData objects
            let context = CoreDataStack.shared.persistentContainer.viewContext
            
            // Convert Firestore documents to StudyPalTask objects
            var tasks: [StudyPalTask] = []
            
            for document in snapshot.documents {
                let data = document.data()
                
                let task = StudyPalTask(context: context)
                task.id = data["id"] as? String
                task.name = data["name"] as? String
                task.taskDesc = data["taskDesc"] as? String
                task.createdBy = data["createdBy"] as? String
                task.completed = data["completed"] as? Bool ?? false
                
                // Handle date conversion
                if let dueDate = data["dueDate"] as? Timestamp {
                    task.dueDate = dueDate.dateValue()
                }
                
                if let completionDate = data["completionDate"] as? Timestamp {
                    task.completionDate = completionDate.dateValue()
                }
                
                task.completionNotes = data["completionNotes"] as? String
                
                // Handle isAllDay
                task.isAllDay = data["isAllDay"] as? Bool ?? false
                
                // Handle category
                if let categoryName = data["categoryName"] as? String,
                   let categoryColor = data["categoryColor"] as? String {
                    let category = Category(context: context)
                    category.id = data["categoryId"] as? String
                    category.name = categoryName
                    category.color = categoryColor
                    task.category = category
                }
                
                tasks.append(task)
            }
            
            return tasks
        } catch {
            print("Error fetching tasks from Firestore: \(error)")
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
        
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        // Reference to the task document
        let taskRef = db.collection("users").document(userId).collection("tasks").document(taskId)
        
        do {
            // Verify task exists
            let document = try await taskRef.getDocument()
            guard document.exists else {
                throw TaskServiceError.taskNotFound
            }
            
            // Prepare data for update
            var updateData: [String: Any] = [
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            // Add fields to update if they're provided
            if let name = name {
                updateData["name"] = name
            }
            
            if let description = description {
                updateData["taskDesc"] = description
            }
            
            if let dueDate = dueDate {
                updateData["dueDate"] = dueDate
            }
            
            if let isAllDay = isAllDay {
                updateData["isAllDay"] = isAllDay
            }
            
            if let completed = completed {
                updateData["completed"] = completed
                
                // If task is being completed and no completion date provided, set it to now
                if completed && completionDate == nil {
                    updateData["completionDate"] = FieldValue.serverTimestamp()
                }
            }
            
            if let completionDate = completionDate {
                updateData["completionDate"] = completionDate
            }
            
            if let completionNotes = completionNotes {
                updateData["completionNotes"] = completionNotes
            }
            
            // Update category if specified
            if let categoryName = categoryName, !categoryName.isEmpty {
                let category = try await getOrCreateCategory(name: categoryName, color: categoryColor ?? "blue")
                updateData["categoryId"] = category.id
                updateData["categoryName"] = category.name
                updateData["categoryColor"] = category.color
            }
            
            // Update Firestore
            try await taskRef.updateData(updateData)
            
            // Get updated task data
            let updatedDocument = try await taskRef.getDocument()
            let data = updatedDocument.data() ?? [:]
            
            // Create StudyPalTask for compatibility with UI
            let context = CoreDataStack.shared.persistentContainer.viewContext
            let task = StudyPalTask(context: context)
            
            task.id = taskId
            task.name = data["name"] as? String
            task.taskDesc = data["taskDesc"] as? String
            task.createdBy = data["createdBy"] as? String
            task.completed = data["completed"] as? Bool ?? false
            
            // Handle date conversion
            if let dueDate = data["dueDate"] as? Timestamp {
                task.dueDate = dueDate.dateValue()
            }
            
            if let completionDate = data["completionDate"] as? Timestamp {
                task.completionDate = completionDate.dateValue()
            }
            
            task.completionNotes = data["completionNotes"] as? String
            task.isAllDay = data["isAllDay"] as? Bool ?? false
            
            // Handle category
            if let categoryName = data["categoryName"] as? String,
               let categoryColor = data["categoryColor"] as? String {
                let category = Category(context: context)
                category.id = data["categoryId"] as? String
                category.name = categoryName
                category.color = categoryColor
                task.category = category
            }
            
            return task
        } catch {
            print("Error updating task in Firestore: \(error)")
            throw TaskServiceError.updateFailed
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(taskId: String) async throws -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        let taskRef = db.collection("users").document(userId).collection("tasks").document(taskId)
        
        do {
            // Verify task exists
            let document = try await taskRef.getDocument()
            guard document.exists else {
                throw TaskServiceError.taskNotFound
            }
            
            // Delete the task
            try await taskRef.delete()
            return true
        } catch {
            print("Error deleting task from Firestore: \(error)")
            throw TaskServiceError.deleteFailed
        }
    }
    
    // MARK: - Get Categories
    func getCategories() async throws -> [Category] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        do {
            let snapshot = try await db.collection("users").document(userId).collection("categories").getDocuments()
            
            let context = CoreDataStack.shared.persistentContainer.viewContext
            var categories: [Category] = []
            
            for document in snapshot.documents {
                let data = document.data()
                
                let category = Category(context: context)
                category.id = document.documentID
                category.name = data["name"] as? String
                category.color = data["color"] as? String
                
                categories.append(category)
            }
            
            return categories
        } catch {
            print("Error fetching categories from Firestore: \(error)")
            throw TaskServiceError.fetchFailed
        }
    }
} 