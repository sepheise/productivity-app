//
//  GetNotesUseCaseTests.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 17-09-22.
//

import XCTest
import ProductivityFW

class GetNotesUseCaseTests: XCTestCase {
    func test_getNotes_deliversEmptyListOnNotFoundNotes() {
        let (sut, store) = makeSUT()
        let date = Date()

        expect(sut: sut, withSinceDate: date, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: .success([]))
        })
    }

    func test_getNotes_deliversErrorOnRetrievalError() {
        let (sut, store) = makeSUT()
        let date = Date()

        expect(sut: sut, withSinceDate: date, toCompleteWith: .failure(.retrievalError), when: {
            store.completeRetrieval(with: .failure(anyNSError()))
        })
    }

    func test_getNotes_requestsToRetrieveWithSinceDate() {
        let (sut, store) = makeSUT()
        let date = Date()

        sut.getNotes(lastUpdatedSince: date) { _ in }

        XCTAssertEqual(store.retrievals.first, date)
    }

    func test_getNotes_deliversNotesLastUpdatedAfterSinceDateSortedByLastUpdatedAt() {
        let (sut, store) = makeSUT()
        let now = Date()
        let beginningOfToday = Calendar(identifier: .gregorian).startOfDay(for: now)
        let oneHourAgoNote = uniqueNote(lastUpdatedAt: now.adding(hours: -1))
        let twoHoursAgoNote = uniqueNote(lastUpdatedAt: now.adding(hours: -2))
        let yesterdayNote = uniqueNote(lastUpdatedAt: now.adding(days: -1))

        let expectedNotes: [Note] = [oneHourAgoNote.model, twoHoursAgoNote.model]

        expect(sut: sut, withSinceDate: beginningOfToday, toCompleteWith: .success(expectedNotes), when: {
            store.completeRetrieval(with: .success([
                twoHoursAgoNote.local,
                oneHourAgoNote.local,
                yesterdayNote.local
            ]))
        })
    }

    func test_getNotes_doesNotDeliverErrorAfterInstanceHasBeenDeallocated() {
        let store = NotesStoreSpy()
        var sut: GetNotesUseCase? = GetNotesUseCase(store: store)
        let now = Date()
        let beginningOfToday = Calendar(identifier: .gregorian).startOfDay(for: now)

        var receivedResults = [GetNotesResult]()
        sut?.getNotes(lastUpdatedSince: beginningOfToday) { receivedResults.append($0) }

        sut = nil
        store.completeRetrieval(with: .failure(anyNSError()))

        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: GetNotesUseCase, store: NotesStoreSpy) {
        let store = NotesStoreSpy()
        let sut = GetNotesUseCase(store: store)

        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)

        return (sut, store)
    }

    private func expect(sut: GetNotesUseCase, withSinceDate date: Date, toCompleteWith expectedResult: GetNotesResult, when action: () -> Void = {}) {
        let exp = expectation(description: "Wait for get notes completion")
        var receivedResult: GetNotesResult?

        sut.getNotes(lastUpdatedSince: date) { result in
            receivedResult = result
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 0.5)

        XCTAssertEqual(receivedResult, expectedResult)
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
