//
//  NotesStore.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 13-09-22.
//

public typealias InsertionResult = Result<LocalNote, Error>

public typealias RetrievalResult = Result<[LocalNote], Error>

public protocol NotesStore {
    func insert(note: LocalNote, completion: @escaping (InsertionResult) -> Void)
}
