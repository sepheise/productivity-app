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

        let exp = expectation(description: "Wait for Note insertion")
        var insertionError: Error?

        sut.insert(note: note) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
        XCTAssertNil(insertionError)
    }

    func test_retrieve_deliversNoneOnNonExistingNote() {
        let sut = try! makeSUT()
        let nonExistingId = UUID()

        let exp = expectation(description: "Wait for Note retrieval")
        var retrievedNote: Note?

        sut.retrieve(id: nonExistingId) { result in
            if case let Result.success(note) = result { retrievedNote = note }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
        XCTAssertEqual(retrievedNote, .none)
    }

    private func makeSUT() throws -> CoreDataNotesStore {
        let testStoreURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataNotesStore(storeURL: testStoreURL)
        return sut
    }
}
