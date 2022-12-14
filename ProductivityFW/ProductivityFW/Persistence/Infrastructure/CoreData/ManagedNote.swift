//
//  ManagedNote.swift
//  ProductivityFW
//
//  Created by Patricio SepĂșlveda Heise on 14-09-22.
//

import CoreData

@objc(ManagedNote)
class ManagedNote: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var content: String
    @NSManaged var lastUpdatedAt: Date
    @NSManaged var lastSavedAt: Date
}

extension ManagedNote {
    static func find(id: UUID, in context: NSManagedObjectContext) throws -> ManagedNote? {
        let request = NSFetchRequest<ManagedNote>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(ManagedNote.id), id])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func find(lastUpdatedSince: Date, in context: NSManagedObjectContext) throws -> [ManagedNote] {
        let request = NSFetchRequest<ManagedNote>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K >= %@", argumentArray: [#keyPath(ManagedNote.lastUpdatedAt), lastUpdatedSince])
        request.sortDescriptors = [NSSortDescriptor(key: "lastUpdatedAt", ascending: false)]
        return try context.fetch(request)
    }
}
