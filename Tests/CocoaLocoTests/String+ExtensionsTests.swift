//
//  String+ExtensionsTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 5/27/19.
//

import XCTest
@testable import CocoaLocoCore

final class StringExtensionsTests: XCTestCase {
    
    func testIndent() {
        XCTAssertEqual("Yay".indented(by: 2), "  Yay")
        XCTAssertEqual("Yay".indented(by: 0), "Yay")
    }
    
    func testCapitalizingFirstLetter() {
        XCTAssertEqual("yay".capitalizingFirstLetter(), "Yay")
        XCTAssertEqual("yAY".capitalizingFirstLetter(), "YAY")
        XCTAssertEqual("YAY".capitalizingFirstLetter(), "YAY")
        XCTAssertEqual("".capitalizingFirstLetter(), "")
    }
    
    func testLowercaseFirstLetter() {
        XCTAssertEqual("Yay".lowercaseFirstLetter(), "yay")
        XCTAssertEqual("YAY".lowercaseFirstLetter(), "yAY")
        XCTAssertEqual("yay".lowercaseFirstLetter(), "yay")
        XCTAssertEqual("".lowercaseFirstLetter(), "")
    }
    
    func testIndentEachLine() {
        let test = """
cool Stuff
oh ya

yay
""".indentEachLine(by: 2)
        XCTAssertEqual(test, """
  cool Stuff
  oh ya

  yay
""")
    }
    
    func testRemoveEmptyLines() {
        let test = """

blah



blahblah

blah

""".removeEmptyLines()
        XCTAssertEqual(test, """
blah
blahblah
blah
""")
    }

}
