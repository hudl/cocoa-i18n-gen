//
//  PluralTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 6/5/19.
//

import Foundation
import XCTest
@testable import CocoaLocoCore

class PluralTests: XCTestCase {
    
    // MARK: - Identifies matches
    
    func testAcceptsBaseCase() {
        let result = Plural.asPlural(["one": "1 clip", "other": "%lu clips"], normalizedName: "name", fullNamespace: "namespace")
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.one, "1 clip")
        XCTAssertEqual(result?.other, "%lu clips")
        XCTAssertNil(result?.comment)
        XCTAssertNil(result?.few)
        XCTAssertNil(result?.zero)
        XCTAssertNil(result?.two)
        XCTAssertEqual(result?.normalizedName, "name")
        XCTAssertEqual(result?.fullNamespace, "namespace")
    }
    
    func testAcceptsAllValues() {
        let result = Plural.asPlural([
            "one": "1 clip",
            "other": "%lu clips",
            "few": "%lu clips few",
            "zero": "%lu clips zero",
            "two": "%lu clips two",
            "comment": "number of clips in a playlist",
        ], normalizedName: "name", fullNamespace: "namespace")
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.one, "1 clip")
        XCTAssertEqual(result?.other, "%lu clips")
        XCTAssertEqual(result?.comment, "number of clips in a playlist")
        XCTAssertEqual(result?.few, "%lu clips few")
        XCTAssertEqual(result?.zero, "%lu clips zero")
        XCTAssertEqual(result?.two, "%lu clips two")
        XCTAssertEqual(result?.normalizedName, "name")
        XCTAssertEqual(result?.fullNamespace, "namespace")
    }
    
    func testRejectsOnlyOne() {
        let result = Plural.asPlural(["one": "1 clip"], normalizedName: "name", fullNamespace: "namespace")
        XCTAssertNil(result)
    }
    
    func testRejectsOnlyOther() {
        let result = Plural.asPlural(["other": "%lu clips"], normalizedName: "name", fullNamespace: "namespace")
        XCTAssertNil(result)
    }
    
    func testRejectsBadTypes() {
        let result = Plural.asPlural(1, normalizedName: "name", fullNamespace: "namespace")
        XCTAssertNil(result)
        let result2 = Plural.asPlural("test", normalizedName: "name", fullNamespace: "namespace")
        XCTAssertNil(result2)
    }
    
    // MARK: - Swift conversation
    
    // MARK: - Objective-C conversation
    
    // MARK: - XML conversation
    
}
