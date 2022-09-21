//
//  GetNotesUseCase.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 21-09-22.
//

import Foundation

public class GetNotesUseCase {
    private let store: NotesStore

    public init(store: NotesStore) {
        self.store = store
    }

    public func getNotes(lastUpdatedSince date: Date, completion: @escaping (GetNotesResult) -> Void) {
        store.retrieve(lastUpdatedSince: date) { result in
            switch result {
            case .success(let localNotes):
                completion(.success(
                    localNotes
                        .filtered(sinceLastUpdated: date)
                        .sortedByLastUpdated()
                        .toModels()))
            case .failure:
                completion(.failure(.retrievalError))
            }
        }
    }
}

public enum GetNotesError: Error {
    case retrievalError
}

public typealias GetNotesResult = Result<[Note], GetNotesError>

private extension Array where Element == LocalNote {
    func filtered(sinceLastUpdated date: Date) -> [LocalNote] {
        return filter { $0.lastUpdatedAt >= date }
    }

    func sortedByLastUpdated() -> [LocalNote] {
        return sorted { $0.lastUpdatedAt > $1.lastUpdatedAt }
    }

    func toModels() -> [Note] {
        return map { Note(id: $0.id, content: $0.content, lastUpdatedAt: $0.lastUpdatedAt, lastSavedAt: $0.lastSavedAt) }
    }
}
