//
//  NotesStoreSpy.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 17-09-22.
//

import Foundation
import ProductivityFW

class NotesStoreSpy: NotesStore {
    var insertions = [LocalNote]()
    var retrievals = [Date]()
    private var insertionCompletion: (InsertionResult) -> Void = { _ in }
    private var retrievalCompletion: (RetrievalResult) -> Void = { _ in }

    func insert(note: LocalNote, completion: @escaping (InsertionResult) -> Void) {
        insertions.append(note)
        insertionCompletion = completion
    }

    func retrieve(since: Date, completion: @escaping (RetrievalResult) -> Void) {
        retrievals.append(since)
        retrievalCompletion = completion
    }

    func completeInsertion(with result: InsertionResult) {
        insertionCompletion(result)
    }

    func completeRetrieval(with result: RetrievalResult) {
        retrievalCompletion(result)
    }
}
