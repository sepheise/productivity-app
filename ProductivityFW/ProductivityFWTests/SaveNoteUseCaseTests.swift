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
        let invalidNote = uniqueNote(content: invalidContent).model

        expect(sut: sut, with: invalidNote, toCompleteWith: .failure(.invalidContent))
    }

    func test_save_doestNotRequestToInsertOnInvalidContent() {
        let (sut, store) = makeSUT()
        let invalidContent = ""
        let invalidNote = uniqueNote(content: invalidContent).model

        sut.save(note: invalidNote) { _ in }

        XCTAssertEqual(store.insertions.count, 0)
    }

    func test_save_requestsToInsertOnValidContentWithLastSavedAtTimestamp() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let note = uniqueNote().model

        sut.save(note: note) { _ in }

        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.id, note.id)
        XCTAssertEqual(store.insertions.first?.content, note.content)
        XCTAssertEqual(store.insertions.first?.lastSavedAt, timestamp)
    }

    func test_save_deliversInsertionErrorOnInsertionFailure() {
        let (sut, store) = makeSUT()
        let note = uniqueNote().model

        expect(sut: sut, with: note, toCompleteWith: .failure(.insertionError)) {
            store.completeInsertion(with: .failure(anyNSError()))
        }
    }

    func test_save_deliversSuccessOnInsertionSuccess() {
        let (sut, store) = makeSUT()
        let note = uniqueNote()

        expect(sut: sut, with: note.model, toCompleteWith: .success(note.model)) {
            store.completeInsertion(with: .success(note.local))
        }
    }

    func test_save_doesNoteSaveNotesAfterInstanceHasBeenDeallocated() {
        let store = NotesStoreSpy()
        let note = uniqueNote()
        var sut: SaveNoteUseCase? = SaveNoteUseCase(store: store, currentDate: { Date() })

        var receivedResults = [SaveNoteResult]()

        sut?.save(note: note.model) { receivedResults.append($0) }

        sut = nil
        store.completeInsertion(with: .success(note.local))

        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_save_doesNotDeliverErrorAfterInstanceHasBeenDeallocated() {
        let store = NotesStoreSpy()
        var sut: SaveNoteUseCase? = SaveNoteUseCase(store: store, currentDate: { Date() })

        var receivedResults = [SaveNoteResult]()

        sut?.save(note: uniqueNote().model) { receivedResults.append($0) }

        sut = nil
        store.completeInsertion(with: .failure(anyNSError()))

        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: SaveNoteUseCase, store: NotesStoreSpy) {
        let store = NotesStoreSpy()
        let sut = SaveNoteUseCase(store: store, currentDate: currentDate)

        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)

        return (sut, store)
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
