//
//  CoreDataStack.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/29/25.
//

import SwiftUI
import CoreData
import Foundation

class CoreDataStack: ObservableObject {
    /* Define a static property that explicitly indicates that this is a shared property across all your app */
    static let shared = CoreDataStack()
    
    /* lazy var ensures that this is only initialized the first time that it is accessed */
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StudyPal")
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    /* Track any changes that you have made to the object and save if there are changes */
    static func save() -> Bool {
        let vc: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
        
        if vc.hasChanges {
            do {
                try vc.save()
                return true
            } catch {
                return false
            }
        }
        
        return true
    }
    
    /* Every time that core data saves, you can basically set up a bridge */
    @objc func coreDataDidSave(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        if let insertedIds = userInfo[NSInsertedObjectIDsKey] as? Set<NSManagedObjectID> {
            print("inserted ids: \(insertedIds)")
        }
        
        if let updatedIds = userInfo[NSUpdatedObjectIDsKey] as? Set<NSManagedObjectID> {
            print("updated ids: \(updatedIds)")
        }
        
        if let deletedIds = userInfo[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID> {
            print("deleted ids: \(deletedIds)")
        }
        
    }
    
    /* This private init() ensures that no other file in the app can access the initializer for CoreDataStack */
    private init() {
        
        /* Subscribe to notifications when anything on CoreData changes */
//        NotificationCenter.default.addObserver(self, selector: #selector(coreDataDidSave), name: .NSManagedObjectContextDidSaveObjectIDs, object: CoreDataStack.shared.persistentContainer.viewContext)
        
    }
}
