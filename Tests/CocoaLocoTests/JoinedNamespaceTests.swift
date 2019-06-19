//
//  JoinedNamespaceTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 6/17/19.
//

import Foundation
import XCTest
@testable import CocoaLocoCore

class JoinedNamespaceTests: XCTestCase {
    
    func testNeitherNil() {
        let result = joinedNamespace(part1: nil, part2: "Tester")
        XCTAssertEqual(result, "Tester")
    }
    
    func testParentNil() {
        let result = joinedNamespace(part1: "Part1", part2: "Tester")
        XCTAssertEqual(result, "Part1.Tester")
    }
    
}
