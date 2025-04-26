import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Task Firebase Model
struct TaskFirebaseModel: Identifiable, Codable {
    var id: String
    var name: String
    var taskDesc: String?
    var dueDate: Date?
    var createdBy: String
    var completed: Bool
    var isAllDay: Bool
    var completionDate: Date?
    var completionNotes: String?
    var categoryId: String?
    var categoryName: String?
    var categoryColor: String?
    
    // Constructor from StudyPalTask
    init(from task: StudyPalTask) {
        self.id = task.id ?? UUID().uuidString
        self.name = task.name ?? ""
        self.taskDesc = task.taskDesc
        self.dueDate = task.dueDate
        self.createdBy = task.createdBy ?? Auth.auth().currentUser?.uid ?? "unknown"
        self.completed = task.completed
        self.isAllDay = task.isAllDay
        self.completionDate = task.completionDate
        self.completionNotes = task.completionNotes
        self.categoryId = task.category?.id
        self.categoryName = task.category?.name
        self.categoryColor = task.category?.color
    }
    
    // Constructor for new task
    init(id: String = UUID().uuidString,
         name: String,
         taskDesc: String? = nil,
         dueDate: Date? = nil,
         createdBy: String? = nil,
         completed: Bool = false,
         isAllDay: Bool = false,
         completionDate: Date? = nil,
         completionNotes: String? = nil,
         categoryId: String? = nil,
         categoryName: String? = nil,
         categoryColor: String? = nil) {
        
        self.id = id
        self.name = name
        self.taskDesc = taskDesc
        self.dueDate = dueDate
        self.createdBy = createdBy ?? Auth.auth().currentUser?.uid ?? "unknown"
        self.completed = completed
        self.isAllDay = isAllDay
        self.completionDate = completionDate
        self.completionNotes = completionNotes
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.categoryColor = categoryColor
    }
    
    // Firebase document conversion
    func toFirebaseData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "name": name,
            "createdBy": createdBy,
            "completed": completed,
            "isAllDay": isAllDay
        ]
        
        // Add optional fields
        if let taskDesc = taskDesc { data["taskDesc"] = taskDesc }
        if let dueDate = dueDate { data["dueDate"] = Timestamp(date: dueDate) }
        if let completionDate = completionDate { data["completionDate"] = Timestamp(date: completionDate) }
        if let completionNotes = completionNotes { data["completionNotes"] = completionNotes }
        if let categoryId = categoryId { data["categoryId"] = categoryId }
        if let categoryName = categoryName { data["categoryName"] = categoryName }
        if let categoryColor = categoryColor { data["categoryColor"] = categoryColor }
        
        return data
    }
    
    // Create from Firebase document
    static func fromFirebaseDocument(_ document: DocumentSnapshot) -> TaskFirebaseModel? {
        guard let data = document.data() else { return nil }
        
        let id = data["id"] as? String ?? document.documentID
        guard let name = data["name"] as? String else { return nil }
        let taskDesc = data["taskDesc"] as? String
        let dueDate = (data["dueDate"] as? Timestamp)?.dateValue()
        let createdBy = data["createdBy"] as? String ?? "unknown"
        let completed = data["completed"] as? Bool ?? false
        let isAllDay = data["isAllDay"] as? Bool ?? false
        let completionDate = (data["completionDate"] as? Timestamp)?.dateValue()
        let completionNotes = data["completionNotes"] as? String
        let categoryId = data["categoryId"] as? String
        let categoryName = data["categoryName"] as? String
        let categoryColor = data["categoryColor"] as? String
        
        return TaskFirebaseModel(
            id: id,
            name: name,
            taskDesc: taskDesc,
            dueDate: dueDate,
            createdBy: createdBy,
            completed: completed,
            isAllDay: isAllDay,
            completionDate: completionDate,
            completionNotes: completionNotes,
            categoryId: categoryId,
            categoryName: categoryName,
            categoryColor: categoryColor
        )
    }
}

// MARK: - Category Firebase Model
struct CategoryFirebaseModel: Identifiable, Codable {
    var id: String
    var name: String
    var color: String
    
    // Constructor from Category
    init(from category: Category) {
        self.id = category.id ?? UUID().uuidString
        self.name = category.name ?? ""
        self.color = category.color ?? "blue"
    }
    
    // Constructor for new category
    init(id: String = UUID().uuidString,
         name: String,
         color: String = "blue") {
        self.id = id
        self.name = name
        self.color = color
    }
    
    // Firebase document conversion
    func toFirebaseData() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "color": color
        ]
    }
    
    // Create from Firebase document
    static func fromFirebaseDocument(_ document: DocumentSnapshot) -> CategoryFirebaseModel? {
        guard let data = document.data() else { return nil }
        
        let id = data["id"] as? String ?? document.documentID
        guard let name = data["name"] as? String else { return nil }
        let color = data["color"] as? String ?? "blue"
        
        return CategoryFirebaseModel(
            id: id,
            name: name,
            color: color
        )
    }
}

// MARK: - FirebaseTaskService
class FirebaseTaskService {
    static let shared = FirebaseTaskService()
    
    private let db = Firestore.firestore()
    private let tasksCollection = "tasks"
    private let categoriesCollection = "categories"
    
    private init() {}
    
    // MARK: - Create Task
    func createTask(name: String, 
                   description: String? = nil,
                   dueDate: Date? = nil,
                   isAllDay: Bool = false,
                   categoryName: String? = nil,
                   categoryColor: String? = nil,
                   hasGroup: Bool = false) async throws -> TaskFirebaseModel {
        
        let userId = Auth.auth().currentUser?.uid ?? "unknown"
        
        // Handle category if specified
        var categoryId: String? = nil
        if let categoryName = categoryName, !categoryName.isEmpty {
            let category = try await getOrCreateCategory(name: categoryName, color: categoryColor ?? "blue")
            categoryId = category.id
        }
        
        // Create task model
        let taskModel = TaskFirebaseModel(
            name: name,
            taskDesc: description,
            dueDate: dueDate,
            createdBy: userId,
            completed: false,
            isAllDay: isAllDay,
            categoryId: categoryId,
            categoryName: categoryName,
            categoryColor: categoryColor
        )
        
        // Create task document
        let taskRef = db.collection(tasksCollection).document(taskModel.id)
        try await taskRef.setData(taskModel.toFirebaseData())
        
        return taskModel
    }
    
    // MARK: - Get or Create Category
    private func getOrCreateCategory(name: String, color: String) async throws -> CategoryFirebaseModel {
        // Try to fetch an existing category with this name
        let categoriesRef = db.collection(categoriesCollection)
        let query = categoriesRef.whereField("name", isEqualTo: name).limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        if let document = snapshot.documents.first, let category = CategoryFirebaseModel.fromFirebaseDocument(document) {
            return category
        } else {
            // Create a new category
            let newCategory = CategoryFirebaseModel(name: name, color: color)
            let categoryRef = categoriesRef.document(newCategory.id)
            try await categoryRef.setData(newCategory.toFirebaseData())
            
            return newCategory
        }
    }
    
    // MARK: - Get Tasks
    func getTasks(completed: Bool? = nil) async throws -> [TaskFirebaseModel] {
        let userId = Auth.auth().currentUser?.uid
        
        var query: Query = db.collection(tasksCollection)
        
        // Add filter for user
        if let userId = userId {
            query = query.whereField("createdBy", isEqualTo: userId)
        }
        
        // Add filter for completion status if specified
        if let completed = completed {
            query = query.whereField("completed", isEqualTo: completed)
        }
        
        // Sort by due date
        query = query.order(by: "dueDate", descending: false)
        
        let snapshot = try await query.getDocuments()
        
        var tasks: [TaskFirebaseModel] = []
        for document in snapshot.documents {
            if let task = TaskFirebaseModel.fromFirebaseDocument(document) {
                tasks.append(task)
            }
        }
        
        return tasks
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
                   categoryColor: String? = nil) async throws -> TaskFirebaseModel {
        
        let taskRef = db.collection(tasksCollection).document(taskId)
        let document = try await taskRef.getDocument()
        
        guard document.exists else {
            throw FirebaseAPIErrors.errorParsingFirestoreDocument
        }
        
        var updateData: [String: Any] = [:]
        
        // Update task properties if provided
        if let name = name { updateData["name"] = name }
        if let description = description { updateData["taskDesc"] = description }
        if let dueDate = dueDate { updateData["dueDate"] = Timestamp(date: dueDate) }
        if let isAllDay = isAllDay { updateData["isAllDay"] = isAllDay }
        if let completed = completed { 
            updateData["completed"] = completed 
            
            // If task is being completed, set completion date
            if completed && completionDate == nil {
                updateData["completionDate"] = Timestamp(date: Date())
            }
        }
        if let completionDate = completionDate { updateData["completionDate"] = Timestamp(date: completionDate) }
        if let completionNotes = completionNotes { updateData["completionNotes"] = completionNotes }
        
        // Update category if specified
        if let categoryName = categoryName, !categoryName.isEmpty {
            let category = try await getOrCreateCategory(name: categoryName, color: categoryColor ?? "blue")
            updateData["categoryId"] = category.id
            updateData["categoryName"] = category.name
            updateData["categoryColor"] = category.color
        }
        
        // Update task document
        try await taskRef.updateData(updateData)
        
        // Fetch updated task
        let updatedDocument = try await taskRef.getDocument()
        guard let updatedTask = TaskFirebaseModel.fromFirebaseDocument(updatedDocument) else {
            throw FirebaseAPIErrors.errorParsingFirestoreDocument
        }
        
        return updatedTask
    }
    
    // MARK: - Delete Task
    func deleteTask(taskId: String) async throws -> Bool {
        let taskRef = db.collection(tasksCollection).document(taskId)
        try await taskRef.delete()
        return true
    }
    
    // MARK: - Get Categories
    func getCategories() async throws -> [CategoryFirebaseModel] {
        let snapshot = try await db.collection(categoriesCollection).getDocuments()
        
        var categories: [CategoryFirebaseModel] = []
        for document in snapshot.documents {
            if let category = CategoryFirebaseModel.fromFirebaseDocument(document) {
                categories.append(category)
            }
        }
        
        return categories
    }
} 