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
        let invalidNote = Note(id: UUID(), content: invalidContent)

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
        let invalidNote = Note(id: UUID(), content: invalidContent)

        sut.save(note: invalidNote) { _ in }

        XCTAssertEqual(store.retrievalsCount, 0)
    }

    func test_save_requestsToInsertOnValidContent() {
        let (sut, store) = makeSUT()
        let note = Note(id: UUID(), content: "A note")

        sut.save(note: note) { _ in }

        XCTAssertEqual(store.insertionsCount, 1)
    }

    private func makeSUT() -> (sut: SaveNoteUseCase, store: NotesStoreSpy) {
        let store = NotesStoreSpy()
        let sut = SaveNoteUseCase(store: store)
        return (sut, store)
    }
}

class NotesStoreSpy: NotesStore {
    var retrievalsCount = 0
    var insertionsCount = 0

    func insert(note: Note) {
        insertionsCount += 1
    }
}
