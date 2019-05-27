import XCTest
@testable import cocoa_i18n

final class cocoa_i18nTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(cocoa_i18n().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
