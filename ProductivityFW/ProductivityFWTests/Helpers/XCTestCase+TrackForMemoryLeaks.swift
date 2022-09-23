//
//  XCTestCase+TrackForMemoryLeaks.swift
//  ProductivityFWTests
//
//  Created by Patricio Sepúlveda Heise on 17-09-22.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance of \(String(describing: instance)) should have been deallocated. Potential Memory leak.")
        }
    }
}
