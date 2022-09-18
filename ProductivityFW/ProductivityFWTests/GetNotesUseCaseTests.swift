//
//  GetNotesUseCaseTests.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 17-09-22.
//

import XCTest
import ProductivityFW

class GetNotesUseCase {
    private let store: NotesStore

    init(store: NotesStore) {
        self.store = store
    }

    func getNotes(since date: Date, completion: @escaping (GetNotesResult) -> Void) {
        store.retrieve(since: date) { result in
            switch result {
            case .success:
                completion(.success([]))
            case .failure:
                completion(.failure(.retrievalError))
            }
        }
    }
}

enum GetNotesError: Error {
    case retrievalError
}

typealias GetNotesResult = Result<[Note], GetNotesError>

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

        sut.getNotes(since: date) { _ in }

        XCTAssertEqual(store.retrievals.first, date)
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

        sut.getNotes(since: date) { result in
            receivedResult = result
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 0.5)

        XCTAssertEqual(receivedResult, expectedResult)
    }
}
