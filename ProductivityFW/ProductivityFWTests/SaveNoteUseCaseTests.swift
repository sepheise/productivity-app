//
//  SaveNoteUseCaseTests.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 13-09-22.
//

import XCTest
import ProductivityFW

class SaveNoteUseCaseTests: XCTestCase {
    func test_save_deliversInvalidContentErrorOnInvalidContent() {
        let (sut, _) = makeSUT()
        let invalidContent = ""
        let invalidNote = uniqueNote(content: invalidContent)

        expect(sut: sut, with: invalidNote, toCompleteWith: .failure(.invalidContent))
    }

    func test_save_doestNotRequestToInsertOnInvalidContent() {
        let (sut, store) = makeSUT()
        let invalidContent = ""
        let invalidNote = uniqueNote(content: invalidContent)

        sut.save(note: invalidNote) { _ in }

        XCTAssertEqual(store.insertions.count, 0)
    }

    func test_save_requestsToInsertOnValidContentWithLastSavedAtTimestamp() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let note = uniqueNote()

        sut.save(note: note) { _ in }

        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.id, note.id)
        XCTAssertEqual(store.insertions.first?.content, note.content)
        XCTAssertEqual(store.insertions.first?.lastSavedAt, timestamp)
    }

    func test_save_deliversInsertionErrorOnInsertionFailure() {
        let (sut, store) = makeSUT()
        let note = uniqueNote()

        expect(sut: sut, with: note, toCompleteWith: .failure(.insertionError)) {
            store.completeInsertion(with: .failure(anyNSError()))
        }
    }

    func test_save_deliversSuccessOnInsertionSuccess() {
        let (sut, store) = makeSUT()
        let note = uniqueNote()

        expect(sut: sut, with: note, toCompleteWith: .success(note)) {
            store.completeInsertion(with: .success(note))
        }
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: SaveNoteUseCase, store: NotesStoreSpy) {
        let store = NotesStoreSpy()
        let sut = SaveNoteUseCase(store: store, currentDate: currentDate)
        return (sut, store)
    }

    private func uniqueNote(content: String = "A note") -> Note {
        return Note(id: UUID(), content: content, lastSavedAt: nil)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    private func expect(sut: SaveNoteUseCase, with note: Note, toCompleteWith expectedResult: SaveNoteResult, when action: () -> Void = {}) {
        let exp = expectation(description: "Wait for save note completion")
        var receivedResult: SaveNoteResult?

        sut.save(note: note) { result in
            receivedResult = result
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 0.5)

        XCTAssertEqual(receivedResult, expectedResult)
    }
}

class NotesStoreSpy: NotesStore {
    var insertions = [Note]()
    private var insertionCompletion: (InsertionResult) -> Void = { _ in }

    func insert(note: Note, completion: @escaping (InsertionResult) -> Void) {
        insertions.append(note)
        insertionCompletion = completion
    }

    func completeInsertion(with result: InsertionResult) {
        insertionCompletion(result)
    }
}
