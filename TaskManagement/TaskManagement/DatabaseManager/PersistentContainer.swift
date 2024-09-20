//
//  PersistentContainer.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import CoreData

class PersistenceContainer {
        
    static let shared = PersistenceContainer()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskDB")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        let context = persistentContainer.viewContext
        let entityName = String(describing: type)
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Failed to create entity of type \(entityName)")
        }
        return T(entity: entity, insertInto: context)
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch \(type): \(error)")
            return []
        }
    }
    
    func update<T: NSManagedObject>(_ object: T) {
        saveContext()
    }
    
    func delete<T: NSManagedObject>(_ object: T) {
        let context = persistentContainer.viewContext
        context.delete(object)
        saveContext()
    }
}
