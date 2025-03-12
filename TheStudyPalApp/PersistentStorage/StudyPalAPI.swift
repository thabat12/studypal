//
//  StudyPalAPI.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/11/25.
//
import FirebaseAuth
import FirebaseFirestore

enum FirebaseAPIErrors: Error {
    case userNotSignedIn
    case firebaseFunctionFailed
    case errorParsingFirestoreDocument
    case userAlreadyInGroup
    case groupChatNotFound
}

class StudyPalAPI {
    /*
     Abstracting all the database functions in one file so the logic will all be in one place
     
        This file deals with all the document / collection updates required for our app's backend logic, and every component in this app will use the the functions in here to communicate with the "API".
     */
    
    static private var db: Firestore = {
        return Firestore.firestore()
    }()
    
    
    static func updateUserDetailsFirestore() async throws -> Bool {
        // Writes a fresh copy of the user's details to Cloud Firestore, potentially updating any relevant metadata.
        if let user = Auth.auth().currentUser {
            do {
            
                try await StudyPalAPI.db.collection("users").addDocument(data: [
                    "id": user.uid,
                    "displayName": user.displayName ?? "Unknown"
                ])
                
                return true
            } catch {
                throw FirebaseAPIErrors.firebaseFunctionFailed
            }
            
        } else {
            return false
        }
        
    }
    
    static func createGroupChat(groupChatName: String, privacySetting: Bool) async throws -> Void {
        if let uid = Auth.auth().currentUser?.uid {
            
            let groupChatRef = StudyPalAPI.db.collection("groupChats").document()
            
            try await groupChatRef.setData([
                "id": groupChatRef.documentID, // firebase-generated ID is probably safer anyways
                "name": groupChatName,
                "isPrivate": privacySetting,
                "members": [uid],
                "recentMessage": NSNull()
            ])
            
        } else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
    }
    
    static func joinGroupChat(groupChatId: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
        print(1)
        let groupChatRef = self.db.collection("groupChats").document(groupChatId)
        let documentSnapshot = try await groupChatRef.getDocument()
        print(2)
        
        if documentSnapshot.exists {
            print(3)
            let groupChatData = documentSnapshot.data()
            var members = groupChatData?["members"] as? [String] ?? []
            print(4)
            if !members.contains(uid) {
                members.append(uid)
                print(5)
                try await groupChatRef.updateData([
                    "members": members
                ])
                print(6)
                return true
            } else {
                print(7)
                throw FirebaseAPIErrors.userAlreadyInGroup
            }
        } else {
            print(8)
            throw FirebaseAPIErrors.groupChatNotFound
        }
    }
    
    static func getAllGroupChats(limit: Int = 20) async throws -> [GroupChatInfo] {
        print("get all group chats")
        if let _ = Auth.auth().currentUser?.uid {
            print("uid of user is valid but not using it")
            let groupChatsRef = StudyPalAPI.db.collection("groupChats")
            print("1")
            let snapshotQuery = try await groupChatsRef.whereField("isPrivate", isEqualTo: false).limit(to: limit).getDocuments()
            var groupChats: [GroupChatInfo] = []
            print("2")
            for document in snapshotQuery.documents {
                print("4")
                print(document.data())
                if let groupChat = try GroupChatInfo(dictionary: document.data()) {
                    groupChats.append(groupChat)
                } else {
                    throw FirebaseAPIErrors.errorParsingFirestoreDocument
                }
            }
            print("3")
            
            return groupChats
            
        } else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
    }
    
    static func getAllUserGroupChats() async throws -> [GroupChatInfo] {
        if let uid = Auth.auth().currentUser?.uid {
            
            let groupChatsRef = StudyPalAPI.db.collection("groupChats")
            let snapshotQuery = try await groupChatsRef.whereField("members", arrayContains: uid).getDocuments()
            
            var groupChats: [GroupChatInfo] = []
            
            for document in snapshotQuery.documents {
                if let groupChat = try GroupChatInfo(dictionary: document.data()) {
                    groupChats.append(groupChat)
                } else {
                    throw FirebaseAPIErrors.errorParsingFirestoreDocument
                }
            }
            
            return groupChats
            
        } else {
            throw FirebaseAPIErrors.userNotSignedIn
        }
    }
    
    static func sendMessageToGroupChat(groupChatId: String, message: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw FirebaseAPIErrors.userNotSignedIn }
        
        do {
            let batch = StudyPalAPI.db.batch()
            let groupChatRef = StudyPalAPI.db.collection("groupChats").document(groupChatId)
            let messageRef = groupChatRef.collection("messages").document()
            
            let timestamp = FieldValue.serverTimestamp()
            
            let messageData = [
                "id": messageRef.documentID,
                "sender": uid,
                "message": message,
                "timestamp": timestamp
            ] as [String : Any]
            
            let updatedGroupChat = [
                "recentMessage": message,
                "lastUpdated": timestamp
            ] as [String : Any]
            
            batch.setData(messageData, forDocument: messageRef)
            batch.updateData(updatedGroupChat, forDocument: groupChatRef)
            
            try await batch.commit()
            
            print("batch data success commit")
        } catch {
            throw FirebaseAPIErrors.firebaseFunctionFailed
        }
        
    }
}
