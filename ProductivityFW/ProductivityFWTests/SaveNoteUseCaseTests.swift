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

        let exp = expectation(description: "Wait for save note completion")

        sut.save(note: invalidNote) { result in
            switch result {
            case .success(let note):
                XCTFail("Expected error, got success with \(note) instead.")
            case .failure(let error):
                XCTAssertEqual(error, .invalidContent)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
    }

    func test_save_doestNotRequestToRetrieveOnInvalidContent() {
        let (sut, store) = makeSUT()
        let invalidContent = ""
        let invalidNote = uniqueNote(content: invalidContent)

        sut.save(note: invalidNote) { _ in }

        XCTAssertEqual(store.retrievalsCount, 0)
    }

    func test_save_requestsToInsertOnValidContent() {
        let (sut, store) = makeSUT()
        let note = uniqueNote()

        sut.save(note: note) { _ in }

        XCTAssertEqual(store.insertionsCount, 1)
    }

    func test_save_deliversInsertionErrorOnInsertionFailure() {
        let (sut, store) = makeSUT()
        let note = uniqueNote()

        let exp = expectation(description: "Wait for save note completion")
        var receivedResult: SaveNoteResult?

        sut.save(note: note) { result in
            receivedResult = result
            exp.fulfill()
        }

        store.completeInsertion(with: .failure(anyNSError()))
        wait(for: [exp], timeout: 0.5)

        XCTAssertEqual(receivedResult, .failure(.insertionError))
    }

    func test_save_deliversSuccessOnInsertionSuccess() {
        let (sut, store) = makeSUT()
        let note = uniqueNote()

        let exp = expectation(description: "Wait for save note completion")
        var receivedResult: SaveNoteResult?

        sut.save(note: note) { result in
            receivedResult = result
            exp.fulfill()
        }

        store.completeInsertion(with: .success(note))
        wait(for: [exp], timeout: 0.5)

        XCTAssertEqual(receivedResult, .success(note))
    }

    private func makeSUT() -> (sut: SaveNoteUseCase, store: NotesStoreSpy) {
        let store = NotesStoreSpy()
        let sut = SaveNoteUseCase(store: store)
        return (sut, store)
    }

    private func uniqueNote(content: String = "A note") -> Note {
        return Note(id: UUID(), content: content)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}

class NotesStoreSpy: NotesStore {
    var retrievalsCount = 0
    var insertionsCount = 0
    private var insertionCompletion: (InsertionResult) -> Void = { _ in }

    func insert(note: Note, completion: @escaping (InsertionResult) -> Void) {
        insertionsCount += 1
        insertionCompletion = completion
    }

    func completeInsertion(with result: InsertionResult) {
        insertionCompletion(result)
    }
}
