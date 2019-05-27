import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(cocoa_i18nTests.allTests),
    ]
}
#endif
