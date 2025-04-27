//
//  StudyPalAPI.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/11/25.
//
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn

// MARK: FirebaseAPIErrors
enum FirebaseAPIErrors: Error {
    case userNotSignedIn
    case firebaseFunctionFailed
    case errorParsingFirestoreDocument
    case userAlreadyInGroup
    case groupChatNotFound
    case userNotInitializedOnDatabase
}

enum GoogleSignInErrors: Error {
    case accessTokenNotFetchable
}

enum DataErrors: Error {
    case errorParsingData
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
    
    // MARK: db
    static private var db: Firestore = {
        return Firestore.firestore()
    }()
    
    // MARK: storage
    static private var storage: Storage = {
        return Storage.storage()
    }()
    
    // MARK: getGoogleAccessToken
    static private func getGoogleAccessToken(completion: @escaping (String?) -> Void){
        
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            completion(nil)
            return
        }
        
        user.refreshTokensIfNeeded { refreshedUser, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            guard let token = refreshedUser?.accessToken.tokenString else {
                completion(nil)
                return
            }
            
            completion(token)
        }
    }
    
    // Prevent anything from initializing this API service
    private init() { }
    
    
    // MARK: getUid
    static func getUid() async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        return uid
    }
    
    // MARK: getUserDetails
    static func getUserDetails() throws -> User {
        guard let currentUser = Auth.auth().currentUser else { throw FirebaseAPIErrors.userNotSignedIn }
        
        return currentUser
    }
    
    // MARK: updateUserDetailsFirestore
    static func updateUserDetailsFirestore() async -> Bool {
        
        // Writes a fresh copy of the user's details to Cloud Firestore, potentially updating any relevant metadata.
        guard let user = Auth.auth().currentUser else { return false }
        
        do {
            let userDocRef = StudyPalAPI.db.collection("users").document(user.uid)
            
            let document = try await userDocRef.getDocument()
            
            // Create a new user if not existing already
            if !document.exists {
                try await userDocRef.setData([
                    "id": user.uid,
                    "displayName": user.displayName ?? "",
                    "createdAt": FieldValue.serverTimestamp(),
                    "lastActive": FieldValue.serverTimestamp(),
                    "email": user.email ?? ""
                ])
            }
            // update any active fields
            else {
                try await userDocRef.setData([
                    "id": user.uid,
                    "displayName": user.displayName ?? "",
                    "lastActive": FieldValue.serverTimestamp(),
                    "email": user.email ?? ""
                ], merge: true)
            }
        } catch _ {
            return false
        }
        
        return true
    }
    
    // MARK: getGoogleDocsDocuments
    static func getGoogleDocsDocuments(completion: @escaping ([String: Any]?) -> Void) -> Void {
        let requestString = "https://www.googleapis.com/drive/v3/files?q=mimeType='application/vnd.google-apps.document' or mimeType='application/pdf'&fields=nextPageToken, files(id,name,modifiedTime, thumbnailLink)&orderBy=modifiedTime desc"
        
        /*
         Note: request with pagination is like this...
            For demo purposes, we are not going to do pagination
         
         GET https://www.googleapis.com/drive/v3/files
         ?q=(mimeType='application/vnd.google-apps.document'+or+mimeType='application/pdf')+and+trashed=false
         &fields=nextPageToken, files(id,name,modifiedTime,thumbnailLink)
         &orderBy=modifiedTime desc
         &pageToken=next-page-token-string
         
         
         Also a very helpful tool to figure this out:
         https://developers.google.com/oauthplayground
         */
        
        StudyPalAPI.getGoogleAccessToken {
            accessToken in
            
            guard let accessToken = accessToken else {
                return
            }
            
            guard let url = URL(string: requestString) else {
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in

                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    completion(json)
                } catch _ {
                    completion(nil)
                }
            }.resume()
        }
    }
    
    static func getGoogleDocsDocument(fromId id: String, completion: @escaping ([String: Any]?) -> Void) {
        
        StudyPalAPI.getGoogleAccessToken {
            accessToken in
            
            guard accessToken != nil else { return }
//            guard let url = URL(string: )
        }
        
    }
    
    // MARK: uploadImageToFirebase
    static func uploadImageToFirebase(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = self.storage.reference()
        let fileName = "group_images/\(UUID().uuidString).jpg"
        let imageRef = storageRef.child(fileName)
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
        
    }
    
    // MARK: createGroupChat
    static func createGroupChat(
        groupChatName: String,
        groupDescription: String,
        privacySetting: Bool,
        groupImage: UIImage?) async throws -> Bool {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        do {
            var imageURL: String = ""
            // First try uploading the image
            if (groupImage != nil) {
                
                uploadImageToFirebase(image: groupImage!) { result in
                    switch result {
                    case .success(let url):
                        imageURL = url
                        
                        // Now just populate the group chat reference
                        let groupChatRef = StudyPalAPI.db.collection("groupChats").document()
                        
                        Task {
                            try await groupChatRef.setData([
                                "id": groupChatRef.documentID,
                                "adminId": uid,
                                "name": groupChatName,
                                "description": groupDescription,
                                "imageURL": imageURL,
                                "isPrivate": privacySetting,
                                "members": [uid],
                                "recentMessage": NSNull(),
                                "messageCount": 0
                            ])
                        }
                    case .failure(let error):
                        let errorMessage = "failed to upload image: \(error.localizedDescription)"
                        print(errorMessage)
                    }
                }
            }
            
        } // Remove the catch block since no errors are thrown in the do block
        
        return true
    }
    
    
    // MARK: joinGroupChat
    static func joinGroupChat(groupChatId: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        let groupChatRef = self.db.collection("groupChats").document(groupChatId)
        
        do {
            _ = try await groupChatRef.getDocument()
            guard groupChatRef.documentID != "" else { return false }
            
            try await groupChatRef.setData([
                "members": FieldValue.arrayUnion([uid])
            ], merge: true)
            
        } catch _ {
            return false
        }
        
        return true
    }
    
    // MARK: leaveGroupChat
    static func leaveGroupChat(groupChatId: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        let groupChatRef = self.db.collection("groupChats").document(groupChatId)
        
        do {
            try await groupChatRef.updateData([
                "members": FieldValue.arrayRemove([uid])
            ])
            
        } catch _ {
            return false
        }
        
        return true
    }
    
    // MARK: getAllGroupChats
    static func getAllGroupChats(limit: Int = 20) async throws -> [[String: Any]] {
        
        guard let _ = Auth.auth().currentUser?.uid else {
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
    
    // MARK: getAllUserGroupChatsListener
    static func getAllUserGroupChatsListener(updatedUserList: @escaping ([[String: Any]]) -> Void) async throws -> Void {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        
        let groupChatsRef = StudyPalAPI.db.collection("groupChats")
        
        do {
            groupChatsRef.whereField("members", arrayContains: uid)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("Error fetching snapshot: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    var documentData: [[String: Any]] = []
                    
                    for document in snapshot.documents {
                        documentData.append(document.data())
                    }
                    
                    updatedUserList(documentData)
                }
            
        } // Remove the catch block since no errors are thrown in the do block
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
    
    // MARK: queryGroupChatMessages
    static func queryGroupChatMessages(
        groupChatId: String
    ) async throws -> [[String: Any]] {
        
        guard let _ = Auth.auth().currentUser?.uid else {
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
        guard Auth.auth().currentUser?.uid != nil else { throw FirebaseAPIErrors.userNotSignedIn }
        
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
    
    // function for getting the name of the current user
    static func currentUserDisplayName() -> String? {
        guard let user = Auth.auth().currentUser else { return nil }

        if let name = user.displayName, !name.isEmpty {
            return name
        }
        
        return user.email?.components(separatedBy: "@").first
    }
    
    // updatePublicProfileFields
    static func updatePublicProfileFields(
        major: String,
        courses: [String],
        affiliation: String,
        imageURL: String? = nil            // ← ADD
    ) async throws {

        let uid = try await getUid()
        let ref = db.collection("users").document(uid)

        var data: [String: Any] = [
            "major": major,
            "courses": courses,
            "affiliation": affiliation
        ]
        if let imageURL { data["imageURL"] = imageURL }   // ← ADD

        try await ref.setData(data, merge: true)
    }

    // fetchPublicProfileFields
    static func fetchPublicProfileFields() async throws -> [String: Any] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        let snap = try await db.collection("users").document(uid).getDocument()
        return snap.data() ?? [:]
    }
    
    // MARK: uploadProfileImage
    static func uploadProfileImage(_ image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw DataErrors.errorParsingData
        }

        let uid = try await getUid()
        let ref = storage.reference()
                      .child("users/\(uid)/profile.jpg")  

        // Wrap callback Storage API in a continuation
        return try await withCheckedThrowingContinuation { cont in
            ref.putData(data, metadata: nil) { _, error in
                if let error { cont.resume(throwing: error); return }

                ref.downloadURL { url, error in
                    if let error { cont.resume(throwing: error) }
                    else if let url { cont.resume(returning: url.absoluteString) }
                }
            }
        }
    }



    
}

