import XCTest
@testable import CocoaLocoCore

final class CocoaLocoTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Yay".indented(by: 2), "  Yay")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
