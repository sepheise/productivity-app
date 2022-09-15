//
//  NotesStore.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 13-09-22.
//

public typealias InsertionResult = Result<Note, Error>

public protocol NotesStore {
    func insert(note: Note, completion: @escaping (InsertionResult) -> Void)
}
