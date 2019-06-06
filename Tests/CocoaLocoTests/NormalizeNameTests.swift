//
//  NormalizeNameTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 5/29/19.
//

import XCTest
@testable import CocoaLocoCore

final class NormalizeNameTests: XCTestCase {

    func testNames() {
        measure {
            XCTAssertEqual(normalizeName(rawName: "Yay"), "Yay")
            XCTAssertEqual(normalizeName(rawName: "Yay-Yay"), "YayYay")
            XCTAssertEqual(normalizeName(rawName: "Yay-yay"), "YayYay")
            XCTAssertEqual(normalizeName(rawName: "yay-yay"), "yayYay")
            XCTAssertEqual(normalizeName(rawName: "yay-Yay"), "yayYay")
            XCTAssertEqual(normalizeName(rawName: "Yay-Yay-Yay"), "YayYayYay")
            XCTAssertEqual(normalizeName(rawName: "Yay-yay-Yay"), "YayYayYay")
            XCTAssertEqual(normalizeName(rawName: "yay-yay-yay"), "yayYayYay")
            XCTAssertEqual(normalizeName(rawName: "yay-Yay-yay"), "yayYayYay")
            XCTAssertEqual(normalizeName(rawName: "public"), "`public`")
            XCTAssertEqual(normalizeName(rawName: "defaultPlusMore"), "defaultPlusMore")
        }
    }

}
