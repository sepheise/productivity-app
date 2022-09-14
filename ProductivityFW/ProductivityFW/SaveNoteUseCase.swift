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
    case insertionError
}

public class SaveNoteUseCase {
    private let store: NotesStore
    private let currentDate: () -> Date

    public init(store: NotesStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func save(note: Note, completion: @escaping (SaveNoteResult) -> Void) {
        guard !note.content.isEmpty else {
            completion(.failure(.invalidContent))
            return
        }

        let noteWithLastSavedAt = Note(id: note.id, content: note.content, lastSavedAt: currentDate())

        store.insert(note: noteWithLastSavedAt) { result in
            switch result {
            case .success(let note):
                completion(.success(note))
            case .failure(_):
                completion(.failure(.insertionError))
            }
        }
    }
}
