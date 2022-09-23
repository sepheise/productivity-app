//
//  NotesStoreTests.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 14-09-22.
//

import XCTest
import ProductivityFW

class CoreDataNotesStoreTests: XCTestCase {
    func test_insert_deliversNoErrorOnNewNote() {
        let sut = makeSUT()
        let note = uniqueNote().local

        let insertionError = insert(note: note, on: sut)

        XCTAssertNil(insertionError)
    }

    func test_retrieve_deliversNoneOnNonExistingNote() {
        let sut = makeSUT()
        let nonExistingId = UUID()

        expect(sut, with: nonExistingId, toRetrieve: .success(.none))
    }

    func test_retrieve_deliversNoteOnExistingNote() {
        let sut = makeSUT()
        let note = uniqueNote().local

        let _ = insert(note: note, on: sut)

        expect(sut, with: note.id, toRetrieve: .success(note))
    }

    func test_retrieve_hasNoSideEffectsOnExistingNote() {
        let sut = makeSUT()
        let note = uniqueNote().local

        let _ = insert(note: note, on: sut)

        expect(sut, with: note.id, toRetrieveTwice: .success(note))
    }

    func test_insert_updatesExistingNote() {
        let sut = makeSUT()
        let note = uniqueNote().local

        let _ = insert(note: note, on: sut)

        let updatedNote = LocalNote(id: note.id, content: "Updated content", lastUpdatedAt: note.lastUpdatedAt, lastSavedAt: Date())

        let insertionError = insert(note: updatedNote, on: sut)
        XCTAssertNil(insertionError)

        expect(sut, with: note.id, toRetrieve: .success(updatedNote))
    }

    func test_retrieveLastUpdatedSince_deliversNotesLastUpdatedSinceGivenDate() {
        let sut = makeSUT()
        let now = Date()
        let startOfToday = Calendar(identifier: .gregorian).startOfDay(for: now)
        let oneHourAgoNote = uniqueNote(lastUpdatedAt: now.adding(hours: -1)).local
        let twoHoursAgoNote = uniqueNote(lastUpdatedAt: now.adding(hours: -2)).local
        let yesterdayNote = uniqueNote(lastUpdatedAt: now.adding(days: -1)).local
        let expectedRetrivedNotes = [oneHourAgoNote, twoHoursAgoNote]

        let _ = insert(note: oneHourAgoNote, on: sut)
        let _ = insert(note: twoHoursAgoNote, on: sut)
        let _ = insert(note: yesterdayNote, on: sut)

        expect(sut, toRetrieveLastUpdated: .success(expectedRetrivedNotes), since: startOfToday)
    }

    func test_retrieveLastUpdatedSince_deliversEmptyOnNoNotesUpdatedSinceGivenDate() {
        let sut = makeSUT()
        let now = Date()
        let startOfToday = Calendar(identifier: .gregorian).startOfDay(for: now)
        let yesterdayNote = uniqueNote(lastUpdatedAt: now.adding(days: -1)).local

        let _ = insert(note: yesterdayNote, on: sut)

        expect(sut, toRetrieveLastUpdated: .success([]), since: startOfToday)
    }

    func test_retrieveLastUpdatedSince_hasNoSideEffectsOnLastUpdatedSinceGivenDate() {
        let sut = makeSUT()
        let now = Date()
        let startOfToday = Calendar(identifier: .gregorian).startOfDay(for: now)
        let oneHourAgoNote = uniqueNote(lastUpdatedAt: now.adding(hours: -1)).local
        let twoHoursAgoNote = uniqueNote(lastUpdatedAt: now.adding(hours: -2)).local
        let yesterdayNote = uniqueNote(lastUpdatedAt: now.adding(days: -1)).local
        let expectedRetrivedNotes = [oneHourAgoNote, twoHoursAgoNote]

        let _ = insert(note: oneHourAgoNote, on: sut)
        let _ = insert(note: twoHoursAgoNote, on: sut)
        let _ = insert(note: yesterdayNote, on: sut)

        expect(sut, toRetrieveLastUpdatedTwice: .success(expectedRetrivedNotes), since: startOfToday)
    }

    func test_retrieveLastUpdatedSince_hasNoSideEffectsOnNoNotesUpdatedSinceGivenDate() {
        let sut = makeSUT()
        let now = Date()
        let startOfToday = Calendar(identifier: .gregorian).startOfDay(for: now)
        let yesterdayNote = uniqueNote(lastUpdatedAt: now.adding(days: -1)).local

        let _ = insert(note: yesterdayNote, on: sut)

        expect(sut, toRetrieveLastUpdatedTwice: .success([]), since: startOfToday)
    }

    // MARK: - Helpers

    private func makeSUT() -> CoreDataNotesStore {
        let testStoreURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataNotesStore(storeURL: testStoreURL)
        return sut
    }

    private func insert(note: LocalNote, on sut: CoreDataNotesStore) -> Error? {
        let exp = expectation(description: "Wait for Note insertion")
        var insertionError: Error?

        sut.insert(note: note) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
        return insertionError
    }

    private func expect(_ sut: CoreDataNotesStore, with id: UUID, toRetrieve expectedResult: Result<LocalNote?, RetrievalError>) {

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

    private func expect(_ sut: CoreDataNotesStore, toRetrieveLastUpdated expectedResult: RetrievalResult, since date: Date) {
        let exp = expectation(description: "Wait for Notes retrieval")

        sut.retrieve(lastUpdatedSince: date) { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(let expectedNotes), .success(let retrievedNotes)):
                XCTAssertEqual(expectedNotes, retrievedNotes)
            default:
                XCTFail("Expected to retrieve \(String(describing: expectedResult)), got \(String(describing: retrievedResult)) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
    }

    private func expect(_ sut: CoreDataNotesStore, with id: UUID, toRetrieveTwice expectedResult: Result<LocalNote?, RetrievalError>) {
        expect(sut, with: id, toRetrieve: expectedResult)
        expect(sut, with: id, toRetrieve: expectedResult)
    }

    private func expect(_ sut: CoreDataNotesStore, toRetrieveLastUpdatedTwice expectedResult: RetrievalResult, since date: Date) {
        expect(sut, toRetrieveLastUpdated: expectedResult, since: date)
        expect(sut, toRetrieveLastUpdated: expectedResult, since: date)
    }

    private enum RetrievalError: Error {
        case error
    }
}

private extension Date {
    func adding(hours: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .hour, value: hours, to: self)!
    }

    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
