//
//  LocalizationNamespaceTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 6/5/19.
//

import Foundation
import XCTest
@testable import CocoaLocoCore

class LocalizationNamespaceTests: XCTestCase {

    // MARK: - Identifies matches

    func testAcceptsPlural() {
        let dict: [String: Any] = [
            "somePlural": [
                "one": "1 clip",
                "other": "%lu clips"
            ]
        ]
        let result = LocalizationNamespace.parseValue(dict, namespace: "namespace", name: "name", prefix: "")
        XCTAssertEqual(result.plurals.count, 1)
        XCTAssertEqual(result.namespaces.count, 0)
        XCTAssertEqual(result.strings.count, 0)
        XCTAssertEqual(result.normalizedName, "name")
    }

    func testAcceptsString() {
        let dict: [String: Any] = [
            "someString": [
                "value": "yay this is nice"
            ]
        ]
        let result = LocalizationNamespace.parseValue(dict, namespace: "namespace", name: "name", prefix: "")
        XCTAssertEqual(result.plurals.count, 0)
        XCTAssertEqual(result.namespaces.count, 0)
        XCTAssertEqual(result.strings.count, 1)
        XCTAssertEqual(result.normalizedName, "name")
    }

    func testAcceptsNamespace() {
        let dict: [String: Any] = [
            "someNamespace": [
                "somePlural": [
                    "one": "1 clip",
                    "other": "%lu clips"
                ]
            ]
        ]
        let result = LocalizationNamespace.parseValue(dict, namespace: "namespace", name: "name", prefix: "")
        XCTAssertEqual(result.plurals.count, 0)
        XCTAssertEqual(result.namespaces.count, 1)
        XCTAssertEqual(result.namespaces.first?.normalizedName, "someNamespace")
        XCTAssertEqual(result.strings.count, 0)
        XCTAssertEqual(result.normalizedName, "name")
    }

    func testNilNamespace() {
        let dict: [String: Any] = [
            "someString": [
                "value": "yay this is nice"
            ]
        ]
        let result = LocalizationNamespace.parseValue(dict, namespace: nil, name: "name", prefix: "")
        XCTAssertEqual(result.strings.first?.swiftKey, "someString")
        XCTAssertEqual(result.strings.first?.swiftFullFunc, "someString")
    }

    // MARK: - Swift conversation

    func testSwiftSimple() {
        let swift = exampleNamespace.toSwiftCode(indent: 0, visibility: .internal)
        XCTAssertEqual(swift, """
internal enum testName {
internal enum nested {
}
internal static func one(count: Int) -> String { return String.localizedStringWithFormat(_one, count) }
private static let _one = Foundation.NSLocalizedString("oneName.one", bundle: __bundle, comment: "")
internal static func two(count: Int) -> String { return String.localizedStringWithFormat(_two, count) }
private static let _two = Foundation.NSLocalizedString("twoName.two", bundle: __bundle, comment: "")
internal static func one() -> String { return testName._one }
private static let _one = Foundation.NSLocalizedString("oneName.one", bundle: __bundle, value: "test1", comment: "")
internal static func two() -> String { return testName._two }
private static let _two = Foundation.NSLocalizedString("twoName.two", bundle: __bundle, value: "test2", comment: "")
}
""")
    }

    func testSwiftVisibility() {
        let swift = exampleNamespace.toSwiftCode(indent: 0, visibility: .public)
        XCTAssertEqual(swift, """
public enum testName {
public enum nested {
}
public static func one(count: Int) -> String { return String.localizedStringWithFormat(_one, count) }
private static let _one = Foundation.NSLocalizedString("oneName.one", bundle: __bundle, comment: "")
public static func two(count: Int) -> String { return String.localizedStringWithFormat(_two, count) }
private static let _two = Foundation.NSLocalizedString("twoName.two", bundle: __bundle, comment: "")
public static func one() -> String { return testName._one }
private static let _one = Foundation.NSLocalizedString("oneName.one", bundle: __bundle, value: "test1", comment: "")
public static func two() -> String { return testName._two }
private static let _two = Foundation.NSLocalizedString("twoName.two", bundle: __bundle, value: "test2", comment: "")
}
""")
    }

    func testSwiftIndent() {
        let swift = exampleNamespace.toSwiftCode(indent: 4, visibility: .internal)
        XCTAssertEqual(swift, """
internal enum testName {
    internal enum nested {
    }
    internal static func one(count: Int) -> String { return String.localizedStringWithFormat(_one, count) }
    private static let _one = Foundation.NSLocalizedString("oneName.one", bundle: __bundle, comment: "")
    internal static func two(count: Int) -> String { return String.localizedStringWithFormat(_two, count) }
    private static let _two = Foundation.NSLocalizedString("twoName.two", bundle: __bundle, comment: "")
    internal static func one() -> String { return testName._one }
    private static let _one = Foundation.NSLocalizedString("oneName.one", bundle: __bundle, value: "test1", comment: "")
    internal static func two() -> String { return testName._two }
    private static let _two = Foundation.NSLocalizedString("twoName.two", bundle: __bundle, value: "test2", comment: "")
}
""")
    }

    // MARK: - Objective-C conversation

    func testObjcSimple() {
        let objc = exampleNamespace.toObjcCode(visibility: .internal, baseName: "baseBlah")
        XCTAssertEqual(objc, """
  internal static func OneName_One() -> String { return baseBlah.oneName.one() }
  internal static func TwoName_Two() -> String { return baseBlah.twoName.two() }
""")
    }

    func testObjcVisibility() {
        let objc = exampleNamespace.toObjcCode(visibility: .public, baseName: "baseBlah")
        XCTAssertEqual(objc, """
  public static func OneName_One() -> String { return baseBlah.oneName.one() }
  public static func TwoName_Two() -> String { return baseBlah.twoName.two() }
""")
    }
}

private let exampleNestedNamespace = [
    LocalizationNamespace(name: "nested", namespaces: [], strings: [], plurals: [])
]
private let examplePlurals = [
    Plural(key: "one", namespace: "oneName", prefix: "", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)!,
    Plural(key: "two", namespace: "twoName", prefix: "", comment: nil, other: "%lu clips 2", one: "1 clip 2", zero: nil, two: nil, few: nil, many: nil)!
]
private let exampleStrings = [
    LocalizedString(key: "one", namespace: "oneName", value: "test1", prefix: "", comment: nil, arguments: []),
    LocalizedString(key: "two", namespace: "twoName", value: "test2", prefix: "", comment: nil, arguments: [])
]
private let exampleNamespace = LocalizationNamespace(name: "testName",
                                                     namespaces: exampleNestedNamespace,
                                                     strings: exampleStrings,
                                                     plurals: examplePlurals)
