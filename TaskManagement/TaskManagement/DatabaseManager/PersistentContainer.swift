//
//  PersistentContainer.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

@preconcurrency import CoreData

class PersistenceContainer {
        
    static let shared = PersistenceContainer()
    
    let logger: Logger
    
    private let inMemory: Bool
    
    init(inMemory: Bool = false) {
        self.inMemory = inMemory
        logger = Logger(category: "PersisteceContainer")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskDB")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        } else {
            let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let url = storeDirectory.appendingPathComponent("TaskDB.sqlite")
            
            let description = NSPersistentStoreDescription(url: url)
            description.shouldInferMappingModelAutomatically = true
            description.shouldMigrateStoreAutomatically = true
            description.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
            
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        return T(context: context)
    }
    
    @discardableResult
    func create<T: NSManagedObject>(_ type: T.Type, updatedObject: @escaping (T) -> Void) async -> T {
        return await context.perform {
            let object = T(context: self.context)
            updatedObject(object)
            self.saveContext()
            return object
        }
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [T] {
        return try await context.perform {
            let request = NSFetchRequest<T>(entityName: String(describing: type))
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            return try self.context.fetch(request)
        }
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let context = context
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request)
        } catch {
            logger.error("Failed to fetch \(type): \(error)")
            return []
        }
    }
    
    func update<T: NSManagedObject>(_ object: T) {
        saveContext()
    }
    
    func update<T: NSManagedObject>(_ object: T) async {
        await context.perform {
            self.saveContext()
        }
    }
    
    func delete<T: NSManagedObject>(_ object: T) {
        let context = context
        context.delete(object)
        saveContext()
    }
    
    func delete<T: NSManagedObject>(_ object: T) async {
        await self.context.perform {
            self.delete(object)
        }
    }
}
