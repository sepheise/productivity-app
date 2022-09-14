//
//  SaveNoteUseCaseTests.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 13-09-22.
//

import XCTest
import ProductivityFW

class SaveNoteUseCaseTests: XCTestCase {
    func test_save_deliversErrorOnInvalidNote() {
        let sut = SaveNoteUseCase()
        let invalidContent = ""
        let invalidNote = Note(id: UUID(), content: invalidContent)

        let exp = expectation(description: "Wait for save note completion")

        sut.save(note: invalidNote) { result in
            switch result {
            case .success(let note):
                XCTFail("Expected error, got success with \(note) instead.")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
    }
}
