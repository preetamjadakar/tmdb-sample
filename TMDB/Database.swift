//
//  Database.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//

import Foundation
import CoreData

class Database {
    static let shared = Database()
    private var persistentContainer: NSPersistentContainer!

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundContextDidSave(notification:)), name: .NSManagedObjectContextDidSave, object: nil)
    }

    @objc func backgroundContextDidSave(notification: Notification) {
        guard let notificationContext = notification.object as? NSManagedObjectContext else { return }

        guard notificationContext !== context else {
            return
        }

        context.perform {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }

    func performBackgroundTask(block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }

    func prepare() {
        persistentContainer = NSPersistentContainer(name: "TMDB")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
                fatalError()
            }
        }

        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
    }

    func saveContext() {
        do {
            if persistentContainer.viewContext.hasChanges {
                try persistentContainer.viewContext.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func clearStorage() {
        print("CLEARING STORAGE")
        let isInMemoryStore = persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }
        
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            do {
                let movies = try managedObjectContext.fetch(fetchRequest)
                for movie in movies {
                    managedObjectContext.delete(movie as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
}
