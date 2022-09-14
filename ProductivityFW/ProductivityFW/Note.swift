//
//  Note.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 13-09-22.
//

import Foundation

public struct Note {
    let id: UUID
    let content: String

    public init(id: UUID, content: String) {
        self.id = id
        self.content = content
    }
}
