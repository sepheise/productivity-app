//
//  LocalNote.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 15-09-22.
//

import Foundation

/// A Persistence specific Note model.
/// Persistence components should depend on this, instead domain's Note.
public struct LocalNote {
    public let id: UUID
    public let content: String
    public let lastSavedAt: Date

    public init(id: UUID, content: String, lastSavedAt: Date) {
        self.id = id
        self.content = content
        self.lastSavedAt = lastSavedAt
    }
}
