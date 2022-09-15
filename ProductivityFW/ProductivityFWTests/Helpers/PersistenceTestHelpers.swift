//
//  PersistenceTestHelpers.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 15-09-22.
//

import Foundation
import ProductivityFW

public func uniqueNote(content: String = "A note") -> (model: Note, local: LocalNote) {
    let note = Note(id: UUID(), content: content, lastSavedAt: Date())
    let localNote = LocalNote(id: note.id, content: content, lastSavedAt: note.lastSavedAt!)

    return (note, localNote)
}

public func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
