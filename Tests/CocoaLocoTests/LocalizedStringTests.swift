//
//  LocalizedStringTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 6/5/19.
//

import Foundation
import XCTest
@testable import CocoaLocoCore

class LocalizedStringTests: XCTestCase {

    // MARK: - Identifies matches

    func testAcceptsStrings() {
        let result = LocalizedString.asLocalizedString(normalizedName: "name",
                                                       fullNamespace: "namespace",
                                                       prefix: "",
                                                       value: "Test")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, "Test")
        XCTAssertEqual(result?.normalizedName, "name")
        XCTAssertEqual(result?.fullNamespace, "namespace")
        XCTAssertNil(result?.comment)
        XCTAssertEqual(result?.arguments.count, 0)
    }

    func testAcceptsDictionaryWithValue() {
        let result = LocalizedString.asLocalizedString(normalizedName: "name",
                                                       fullNamespace: "namespace",
                                                       prefix: "",
                                                       value: ["value": "Test2"])

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, "Test2")
        XCTAssertEqual(result?.normalizedName, "name")
        XCTAssertEqual(result?.fullNamespace, "namespace")
        XCTAssertNil(result?.comment)
        XCTAssertEqual(result?.arguments.count, 0)
    }

    func testAcceptsDictionaryWithValueAndArgumentsAndComments() {
        let result = LocalizedString.asLocalizedString(normalizedName: "name",
                                                       fullNamespace: "namespace",
                                                       prefix: "",
                                                       value: [
                                                        "value": "Test3 {blah}",
                                                        "comment": "TestComment"
                                                       ])

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, "Test3 {blah}")
        XCTAssertEqual(result?.normalizedName, "name")
        XCTAssertEqual(result?.fullNamespace, "namespace")
        XCTAssertEqual(result?.comment, "TestComment")
        XCTAssertEqual(result?.arguments.count, 1)
        XCTAssertEqual(result?.arguments.first?.name, "blah")
    }

    func testRejectsDictionaryWithoutValue() {
        let result = LocalizedString.asLocalizedString(normalizedName: "name",
                                                       fullNamespace: "namespace",
                                                       prefix: "",
                                                       value: ["blahblah": "Test"])
        XCTAssertNil(result)
    }

    func testRejectsBadTypes() {
        let result = LocalizedString.asLocalizedString(normalizedName: "name",
                                                       fullNamespace: "namespace",
                                                       prefix: "",
                                                       value: 1)
        XCTAssertNil(result)
    }

    // MARK: - Swift conversation

    func testSwiftSimpleCase() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "Namespace", value: "Test", prefix: "", comment: nil, arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .internal, swiftEnum: testNamespace), """
internal static func name() -> String { return bigName._name }
private static let _name = Foundation.NSLocalizedString("Namespace", bundle: __bundle, value: "Test", comment: "")
""")
    }

    func testSwiftComment() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "Namespace", value: "Test", prefix: "", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .internal, swiftEnum: testNamespace), """
internal static func name() -> String { return bigName._name }
private static let _name = Foundation.NSLocalizedString("Namespace", bundle: __bundle, value: "Test", comment: "MyComment")
""")
    }

    func testSwiftArgumentsWithAllType() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "Namespace", value: "Test {number}, {string}, {double}", prefix: "", comment: "MyComment", arguments: [
                Argument(name: "number", type: .number),
                Argument(name: "string", type: .string),
                Argument(name: "double", type: .double)
            ])
        XCTAssertEqual(string.toSwiftCode(visibility: .internal, swiftEnum: testNamespace), """
internal static func name(double: Double, number: Int, string: String) -> String { return String.localizedStringWithFormat(bigName._name, double, number, string) }
private static let _name = Foundation.NSLocalizedString("Namespace", bundle: __bundle, value: "Test %@, %@, %@", comment: "MyComment")
""")
    }
    
    func testSwiftVisibilityModifiers() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "Namespace", value: "Test", prefix: "", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .public, swiftEnum: testNamespace), """
public static func name() -> String { return bigName._name }
private static let _name = Foundation.NSLocalizedString("Namespace", bundle: __bundle, value: "Test", comment: "MyComment")
""")
    }
    
    func testSwiftPrefixTableName() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "Namespace", value: "Test", prefix: "TableName", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .public, swiftEnum: testNamespace), """
public static func name() -> String { return bigName._name }
private static let _name = Foundation.NSLocalizedString("Namespace", tableName: "TableNameLocalizable", bundle: __bundle, value: "Test", comment: "MyComment")
""")
    }

    // MARK: - Objective-C conversation

    func testObjcSimpleCase() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "Namespace", value: "Test", prefix: "", comment: nil, arguments: [])
        XCTAssertEqual(string.toObjcCode(visibility: .internal, baseName: "bigName"), """
internal static func Namespace() -> String { return bigName.Namespace() }
""")
    }

    func testObjcArgumentsWithAllType() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "Namespace", value: "Test {number}, {string}, {double}", prefix: "", comment: "MyComment", arguments: [
            Argument(name: "number", type: .number),
            Argument(name: "string", type: .string),
            Argument(name: "double", type: .double)
            ])
        XCTAssertEqual(string.toObjcCode(visibility: .internal, baseName: "bigName"), """
internal static func Namespace(double: Double, number: Int, string: String) -> String { return bigName.Namespace(double: double, number: number, string: string) }
""")
    }

    func testObjcVisibilityModifiers() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "Namespace", value: "Test", prefix: "", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toObjcCode(visibility: .public, baseName: "bigName"), """
public static func Namespace() -> String { return bigName.Namespace() }
""")
    }

    func testObjcNamespaceNormalized() {
        let string = LocalizedString(normalizedName: "name", fullNamespace: "weird.namespace_with.stuff", value: "Test", prefix: "", comment: nil, arguments: [])
        XCTAssertEqual(string.toObjcCode(visibility: .internal, baseName: "bigName"), """
internal static func Weird_Namespace_with_Stuff() -> String { return bigName.weird.namespace_with.stuff() }
""")
    }

}

private let testNamespace = LocalizationNamespace(normalizedName: "bigName", namespaces: [], strings: [], plurals: [])
