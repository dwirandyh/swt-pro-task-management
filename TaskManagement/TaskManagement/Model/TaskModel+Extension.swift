//
//  TaskModel+Extension.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 21/09/24.
//

import CoreData
import Foundation

extension TaskModel {
    convenience init(from entity: TaskEntity, context: NSManagedObjectContext) {
        self.init(context: context)
        id = entity.id
        title = entity.title
        isCompleted = entity.isCompleted
        lastModified = entity.lastModified ?? Date()
    }
}
