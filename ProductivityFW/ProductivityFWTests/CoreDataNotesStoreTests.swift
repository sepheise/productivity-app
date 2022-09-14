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

    private func makeSUT() throws -> CoreDataNotesStore {
        let testStoreURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataNotesStore(storeURL: testStoreURL)
        return sut
    }
}
