//
//  NotesStoreTests.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 14-09-22.
//

import XCTest
import ProductivityFW

class CoreDataNotesStoreTests: XCTestCase {
    func test_init_deliversNoError() {
        XCTAssertNoThrow(try makeSUT())
    }

    func test_insert_deliversNoErrorOnNewNote() {
        let sut = try! makeSUT()
        let note = Note(id: UUID(), content: "A note", lastSavedAt: Date())

        let insertionError = insert(note: note, on: sut)

        XCTAssertNil(insertionError)
    }

    func test_retrieve_deliversNoneOnNonExistingNote() {
        let sut = try! makeSUT()
        let nonExistingId = UUID()

        expect(sut, with: nonExistingId, toRetrieve: .success(.none))
    }

    func test_retrieve_deliversNoteOnExistingNote() {
        let sut = try! makeSUT()
        let note = Note(id: UUID(), content: "A note", lastSavedAt: Date())

        let _ = insert(note: note, on: sut)

        expect(sut, with: note.id, toRetrieve: .success(note))
    }

    func test_retrieve_hasNoSideEffectsOnExistingNote() {
        let sut = try! makeSUT()
        let note = Note(id: UUID(), content: "A note", lastSavedAt: Date())

        let _ = insert(note: note, on: sut)

        expect(sut, with: note.id, toRetrieveTwice: .success(note))
    }

    func test_insert_updatesExistingNote() {
        let sut = try! makeSUT()
        let note = Note(id: UUID(), content: "A note", lastSavedAt: Date())

        let _ = insert(note: note, on: sut)

        let updatedNote = Note(id: note.id, content: "Updated content", lastSavedAt: Date())

        let insertionError = insert(note: updatedNote, on: sut)
        XCTAssertNil(insertionError)

        expect(sut, with: note.id, toRetrieve: .success(updatedNote))
    }

    // MARK: - Helpers

    private func makeSUT() throws -> CoreDataNotesStore {
        let testStoreURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataNotesStore(storeURL: testStoreURL)
        return sut
    }

    private func insert(note: Note, on sut: CoreDataNotesStore) -> Error? {
        let exp = expectation(description: "Wait for Note insertion")
        var insertionError: Error?

        sut.insert(note: note) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
        return insertionError
    }

    private func expect(_ sut: CoreDataNotesStore, with id: UUID, toRetrieve expectedResult: RetrievalResult) {

        let exp = expectation(description: "Wait for Note retrieval")

        sut.retrieve(id: id) { retrievedResult in
            switch(expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
                (.failure, .failure):
                break

            case let (.success(.some(expected)), .success(.some(retrieved))):
                XCTAssertEqual(retrieved.id, expected.id)
                XCTAssertEqual(retrieved.content, expected.content)
                XCTAssertEqual(retrieved.lastSavedAt, expected.lastSavedAt)

            default:
                XCTFail("Expected to retrieve \(String(describing: expectedResult)), got \(String(describing: retrievedResult)) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
    }

    private func expect(_ sut: CoreDataNotesStore, with id: UUID, toRetrieveTwice expectedResult: RetrievalResult) {
        expect(sut, with: id, toRetrieve: expectedResult)
        expect(sut, with: id, toRetrieve: expectedResult)
    }

    private typealias RetrievalResult = Result<Note?, RetrievalError>

    private enum RetrievalError: Error {
        case error
    }
}
