//
//  Note.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 13-09-22.
//

import Foundation

public struct Note: Equatable {
    public let id: UUID
    public let content: String
    public let lastSavedAt: Date?

    public init(id: UUID, content: String, lastSavedAt: Date?) {
        self.id = id
        self.content = content
        self.lastSavedAt = lastSavedAt
    }
}
