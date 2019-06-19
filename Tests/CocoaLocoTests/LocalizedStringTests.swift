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
        let result = LocalizedString.asLocalizedString(key: "name",
                                                       namespace: "namespace",
                                                       prefix: "",
                                                       value: "Test")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, "Test")
        XCTAssertEqual(result?.normalizedName, "name")
        XCTAssertNil(result?.comment)
        XCTAssertEqual(result?.arguments.count, 0)
    }

    func testAcceptsDictionaryWithValue() {
        let result = LocalizedString.asLocalizedString(key: "name",
                                                       namespace: "namespace",
                                                       prefix: "",
                                                       value: ["value": "Test2"])

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, "Test2")
        XCTAssertEqual(result?.normalizedName, "name")
        XCTAssertNil(result?.comment)
        XCTAssertEqual(result?.arguments.count, 0)
    }

    func testAcceptsDictionaryWithValueAndArgumentsAndComments() {
        let result = LocalizedString.asLocalizedString(key: "name",
                                                       namespace: "namespace",
                                                       prefix: "",
                                                       value: [
                                                        "value": "Test3 {blah}",
                                                        "comment": "TestComment"
                                                       ])

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, "Test3 {blah}")
        XCTAssertEqual(result?.normalizedName, "name")
        XCTAssertEqual(result?.comment, "TestComment")
        XCTAssertEqual(result?.arguments.count, 1)
        XCTAssertEqual(result?.arguments.first?.name, "blah")
    }

    func testRejectsDictionaryWithoutValue() {
        let result = LocalizedString.asLocalizedString(key: "name",
                                                       namespace: "namespace",
                                                       prefix: "",
                                                       value: ["blahblah": "Test"])
        XCTAssertNil(result)
    }

    func testRejectsBadTypes() {
        let result = LocalizedString.asLocalizedString(key: "name",
                                                       namespace: "namespace",
                                                       prefix: "",
                                                       value: 1)
        XCTAssertNil(result)
    }

    // MARK: - Swift conversation

    func testSwiftSimpleCase() {
        let string = LocalizedString(key: "name", namespace: "Namespace", value: "Test", prefix: "", comment: nil, arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .internal, swiftEnum: testNamespace), """
internal static func name() -> String { return bigName._name }
private static let _name = Foundation.NSLocalizedString("Namespace.name", bundle: __bundle, value: "Test", comment: "")
""")
    }

    func testSwiftComment() {
        let string = LocalizedString(key: "name", namespace: "Namespace", value: "Test", prefix: "", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .internal, swiftEnum: testNamespace), """
internal static func name() -> String { return bigName._name }
private static let _name = Foundation.NSLocalizedString("Namespace.name", bundle: __bundle, value: "Test", comment: "MyComment")
""")
    }
    
    func testSwiftNamespaceNormalized() {
        let string = LocalizedString(key: "weird-name_with_stuff", namespace: "weird.namespace_with.stuff", value: "Test", prefix: "", comment: nil, arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .internal, swiftEnum: testNamespace), """
internal static func weirdName_with_stuff() -> String { return bigName._weirdName_with_stuff }
private static let _weirdName_with_stuff = Foundation.NSLocalizedString("weird.namespace_with.stuff.weird-name_with_stuff", bundle: __bundle, value: "Test", comment: "")
""")
    }

    func testSwiftArgumentsWithAllType() {
        let string = LocalizedString(key: "name", namespace: "Namespace", value: "Test {number}, {string}, {double}", prefix: "", comment: "MyComment", arguments: [
                Argument(name: "number", type: .number),
                Argument(name: "string", type: .string),
                Argument(name: "double", type: .double)
            ])
        XCTAssertEqual(string.toSwiftCode(visibility: .internal, swiftEnum: testNamespace), """
internal static func name(double: Double, number: Int, string: String) -> String { return String.localizedStringWithFormat(bigName._name, double, number, string) }
private static let _name = Foundation.NSLocalizedString("Namespace.name", bundle: __bundle, value: "Test %lu, %@, %f", comment: "MyComment")
""")
    }
    
    func testSwiftVisibilityModifiers() {
        let string = LocalizedString(key: "name", namespace: "Namespace", value: "Test", prefix: "", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .public, swiftEnum: testNamespace), """
public static func name() -> String { return bigName._name }
private static let _name = Foundation.NSLocalizedString("Namespace.name", bundle: __bundle, value: "Test", comment: "MyComment")
""")
    }
    
    func testSwiftPrefixTableName() {
        let string = LocalizedString(key: "name", namespace: "Namespace", value: "Test", prefix: "TableName", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .public, swiftEnum: testNamespace), """
public static func name() -> String { return bigName._name }
private static let _name = Foundation.NSLocalizedString("Namespace.name", tableName: "TableNameLocalizable", bundle: __bundle, value: "Test", comment: "MyComment")
""")
    }
    
    func testSwiftWithHyphensInKey() {
        let string = LocalizedString(key: "name-blah-test", namespace: "Namespace-test-yay", value: "Test", prefix: "TableName", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toSwiftCode(visibility: .public, swiftEnum: testNamespace), """
public static func nameBlahTest() -> String { return bigName._nameBlahTest }
private static let _nameBlahTest = Foundation.NSLocalizedString("Namespace-test-yay.name-blah-test", tableName: "TableNameLocalizable", bundle: __bundle, value: "Test", comment: "MyComment")
""")
    }

    // MARK: - Objective-C conversation

    func testObjcSimpleCase() {
        let string = LocalizedString(key: "name", namespace: "Namespace", value: "Test", prefix: "", comment: nil, arguments: [])
        XCTAssertEqual(string.toObjcCode(visibility: .internal, baseName: "bigName"), """
internal static func Namespace_Name() -> String { return bigName.Namespace.name() }
""")
    }

    func testObjcArgumentsWithAllType() {
        let string = LocalizedString(key: "name", namespace: "Namespace", value: "Test {number}, {string}, {double}", prefix: "", comment: "MyComment", arguments: [
            Argument(name: "number", type: .number),
            Argument(name: "string", type: .string),
            Argument(name: "double", type: .double)
            ])
        XCTAssertEqual(string.toObjcCode(visibility: .internal, baseName: "bigName"), """
internal static func Namespace_Name(double: Double, number: Int, string: String) -> String { return bigName.Namespace.name(double: double, number: number, string: string) }
""")
    }

    func testObjcVisibilityModifiers() {
        let string = LocalizedString(key: "name", namespace: "Namespace", value: "Test", prefix: "", comment: "MyComment", arguments: [])
        XCTAssertEqual(string.toObjcCode(visibility: .public, baseName: "bigName"), """
public static func Namespace_Name() -> String { return bigName.Namespace.name() }
""")
    }

    func testObjcNamespaceNormalized() {
        let string = LocalizedString(key: "name-hyphen", namespace: "weird.namespace_with.stuff-hyphen", value: "Test", prefix: "", comment: nil, arguments: [])
        XCTAssertEqual(string.toObjcCode(visibility: .internal, baseName: "bigName"), """
internal static func Weird_Namespace_with_StuffHyphen_NameHyphen() -> String { return bigName.weird.namespace_with.stuffHyphen.nameHyphen() }
""")
    }

}

private let testNamespace = LocalizationNamespace(name: "big-name", namespaces: [], strings: [], plurals: [])
