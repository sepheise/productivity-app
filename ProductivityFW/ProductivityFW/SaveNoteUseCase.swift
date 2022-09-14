//
//  SaveNoteUseCase.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 13-09-22.
//

import Foundation

public typealias SaveNoteResult = Result<Note, SaveNoteError>

public enum SaveNoteError: Error {
    case invalidContent
}

public class SaveNoteUseCase {
    private let store: NotesStore

    public init(store: NotesStore) {
        self.store = store
    }

    public func save(note: Note, completion: @escaping (SaveNoteResult) -> Void) {
        guard !note.content.isEmpty else {
            completion(.failure(.invalidContent))
            return
        }

        store.insert(note: note)

        completion(.failure(.invalidContent))
    }
}
