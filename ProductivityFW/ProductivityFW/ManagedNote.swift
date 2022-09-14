//
//  ManagedNote.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 14-09-22.
//

import CoreData

@objc(ManagedNote)
class ManagedNote: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var content: String
    @NSManaged var lastSavedAt: Date
}
