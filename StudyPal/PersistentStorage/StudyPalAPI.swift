//
//  StudyPalAPI.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/11/25.
//
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: FirebaseAPIErrors
enum FirebaseAPIErrors: Error {
    case userNotSignedIn
    case firebaseFunctionFailed
    case errorParsingFirestoreDocument
    case userAlreadyInGroup
    case groupChatNotFound
    case userNotInitializedOnDatabase
}

// MARK: FileTypes
enum Filetypes {
    case notes
    case image
}

// MARK: StudyPalAPI
class StudyPalAPI {
    /*
     Abstracting all the database functions in one file so the logic will all be in one place
     
        This file deals with all the document / collection updates required for our app's backend logic, and every component in this app will use the the functions in here to communicate with the "API".
     */
    static private var db: Firestore = {
        return Firestore.firestore()
    }()
    
    static private var storage: Storage = {
        return Storage.storage()
    }()
    
    // Prevent anything from initializing this API service
    private init() { }
    
    // MARK: getUid
    static func getUid() async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        return uid
    }
    
    // MARK: updateUserDetailsFirestore
    static func updateUserDetailsFirestore() async -> Bool {
        
        // Writes a fresh copy of the user's details to Cloud Firestore, potentially updating any relevant metadata.
        guard let user = Auth.auth().currentUser else { return false }
        
        do {
            @ServerTimestamp var createdAt: Timestamp?
            let userDocRef = StudyPalAPI.db.collection("users").document(user.uid)
            
            let document = try await userDocRef.getDocument()
            
            // Create a new user if not existing already
            if !document.exists {
                try await userDocRef.setData([
                    "id": user.uid,
                    "displayName": user.displayName ?? "",
                    "createdAt": createdAt!,
                    "lastActive": createdAt!,
                    "email": user.email ?? "",
                    "courses": [],
                    "bio": "",
                    "affiliation": ""
                ])
            }
            // update any active fields
            else {
                try await userDocRef.setData([
                    "id": user.uid,
                    "displayName": user.displayName ?? "",
                    "lastActive": createdAt!,
                    "email": user.email ?? "",
                    "courses": [],
                    "bio": "",
                    "affiliation": ""
                ], merge: true)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    // MARK: createGroupChat
    static func createGroupChat(
        groupChatName: String,
        groupDescription: String,
        privacySetting: Bool) async throws -> Bool {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        do {
            // create the group chat regardless - each one has its own unique document ID
            let groupChatRef = StudyPalAPI.db.collection("groupChats").document()
            
            try await groupChatRef.setData([
                "id": groupChatRef.documentID,
                "adminId": uid,
                "name": groupChatName,
                "description": groupDescription,
                "isPrivate": privacySetting,
                "members": [uid],
                "recentMessage": NSNull(),
                "messageCount": 0
            ])
        } catch {
            return false
        }
        
        return true
    }
    
    
    // MARK: joinGroupChat
    static func joinGroupChat(groupChatId: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        let groupChatRef = self.db.collection("groupChats").document(groupChatId)
        
        do {
            let groupChatDoc = try await groupChatRef.getDocument()
            guard groupChatDoc.exists else { return false }
            
            try await groupChatRef.setData([
                "members": FieldValue.arrayUnion([uid])
            ], merge: true)
            
        } catch {
            return false
        }
        
        return true
    }
    
    // MARK: getAllGroupChats
    static func getAllGroupChats(limit: Int = 20) async throws -> [[String: Any]] {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        let groupChatsRef = StudyPalAPI.db.collection("groupChats")
        
        do {
            let snapshotDocuments = try await groupChatsRef.whereField("isPrivate", isEqualTo: false).limit(to: limit).getDocuments()
            
            var documentData: [[String: Any]] = []
            
            for document in snapshotDocuments.documents {
                documentData.append(document.data())
            }
            
            return documentData
        } catch {
            throw FirebaseAPIErrors.errorParsingFirestoreDocument
        }
    }
    
    // MARK: getAllUserGroupChats
    static func getAllUserGroupChats() async throws -> [[String: Any]] {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        let groupChatsRef = StudyPalAPI.db.collection("groupChats")
        
        do {
            let snapshotDocuments = try await groupChatsRef.whereField("members", arrayContains: uid).getDocuments()
            var documentData: [[String: Any]] = []
            
            for document in snapshotDocuments.documents {
                documentData.append(document.data())
            }
            
            return documentData
        } catch {
            throw FirebaseAPIErrors.errorParsingFirestoreDocument
        }
    }
    
    // MARK: uploadFileToBackend
    static func uploadFileToBackend(
        data: Data,
        filename: String,
        filetype: Filetypes,
        progressHandler: ((_ snapshot: StorageTaskSnapshot) -> Void)?,
        successHandler:  ((_ snapshot: StorageTaskSnapshot) -> Void)?,
        failureHandler:  ((_ snapshot: StorageTaskSnapshot) -> Void)?
    ) async throws -> Bool {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        let userDocRef = StudyPalAPI.db.collection("users").document(uid)
        
        do {
            guard try await userDocRef.getDocument().exists else {
                throw FirebaseAPIErrors.userNotInitializedOnDatabase
            }
            
            let dataRef = storage.reference(forURL: "users/\(uid)/data/\(filename)")
            
            let uploadTask = dataRef.putData(data, metadata: nil)
            
            // Register the handlers for the upload task
            uploadTask.observe(.progress) { progressHandler?($0) }
            uploadTask.observe(.success)  { successHandler?($0) }
            uploadTask.observe(.failure)  { failureHandler?($0) }
        } catch {
            return false
        }
        
        return true
    }
    
    // MARK: sendMessageToGroupChat
    static func sendMessageToGroupChat(
        groupChatId: String,
        message: String,
        replyTo: String,
        attachments: [String]) async throws {
            
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        do {
            let batch = StudyPalAPI.db.batch()
            let groupChatRef = StudyPalAPI.db.collection("groupChats").document(groupChatId)
            
            guard try await groupChatRef.getDocument().exists else { throw FirebaseAPIErrors.groupChatNotFound }
            
            let messageRef = groupChatRef.collection("messages").document()
            
            
            let messageData = [
                "id": messageRef.documentID,
                "sender": uid,
                "message": message,
                "timestamp": FieldValue.serverTimestamp()
            ] as [String : Any]
            
            let updatedGroupChat = [
                "messageCount": FieldValue.increment(1.0),
                "recentMessage": message,
                "lastUpdated": FieldValue.serverTimestamp()
            ] as [String : Any]
            
            batch.setData(messageData, forDocument: messageRef)
            batch.updateData(updatedGroupChat, forDocument: groupChatRef)
            
            try await batch.commit()
            
            print("batch data success commit")
        } catch {
            throw FirebaseAPIErrors.firebaseFunctionFailed
        }
        
    }
    
    static func queryGroupChatMessages(
        groupChatId: String
    ) async throws -> [[String: Any]] {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        let groupChatRef = self.db.collection("groupChats").document(groupChatId)
        
        do {
            
            if try await !groupChatRef.getDocument().exists {
                throw FirebaseAPIErrors.groupChatNotFound
            }
            
            let messageCollectionRef = self.db.collection("groupChats").document(groupChatId).collection("messages")
            
            // Query whatever you need
            let allMessages = try await messageCollectionRef.order(by: "timestamp").getDocuments()
            
            return allMessages.documents.map { $0.data() }
            
        } catch {
            throw FirebaseAPIErrors.firebaseFunctionFailed
        }
    }
    
    // MARK: groupChatMessagesListener
    static func groupChatMessagesListener(
        groupChatId: String,
        onAddedDocuments: @escaping ([DocumentChange]) -> Void
    ) async throws -> ListenerRegistration {
        guard let _ = Auth.auth().currentUser?.uid else { throw FirebaseAPIErrors.userNotSignedIn }
        
        let groupChatRef = self.db.collection("groupChats").document(groupChatId)
            
        do {
            if try await !groupChatRef.getDocument().exists {
                throw FirebaseAPIErrors.groupChatNotFound
            }
            
            let messageCollectionRef = self.db.collection("groupChats").document(groupChatId).collection("messages")
            
            
            // Set up the listener
            let listener = messageCollectionRef.order(by: "timestamp", descending: false).addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening for new documents: \(error.localizedDescription)")
                    return
                }

                // Bind a document change listener here
                if let documentChanges = snapshot?.documentChanges {
                    onAddedDocuments(documentChanges)
                }
                
                }
            
            return listener
        } catch {
            throw FirebaseAPIErrors.firebaseFunctionFailed
        }
    }
}
