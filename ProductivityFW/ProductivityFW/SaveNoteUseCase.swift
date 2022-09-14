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
    public init() {}

    public func save(note: Note, completion: @escaping (SaveNoteResult) -> Void) {
        completion(.failure(.invalidContent))
    }
}
