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
        let result = Plural.asPlural(["one": "1 clip", "other": "%lu clips"], key: "name", namespace: "namespace")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.one, "1 clip")
        XCTAssertEqual(result?.other, "%lu clips")
        XCTAssertNil(result?.comment)
        XCTAssertNil(result?.few)
        XCTAssertNil(result?.zero)
        XCTAssertNil(result?.two)
        XCTAssertEqual(result?.normalizedName, "name")
    }

    func testAcceptsAllValues() {
        let result = Plural.asPlural([
            "one": "1 clip",
            "other": "%lu clips",
            "few": "%lu clips few",
            "zero": "%lu clips zero",
            "two": "%lu clips two",
            "comment": "number of clips in a playlist"
        ], key: "name", namespace: "namespace")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.one, "1 clip")
        XCTAssertEqual(result?.other, "%lu clips")
        XCTAssertEqual(result?.comment, "number of clips in a playlist")
        XCTAssertEqual(result?.few, "%lu clips few")
        XCTAssertEqual(result?.zero, "%lu clips zero")
        XCTAssertEqual(result?.two, "%lu clips two")
        XCTAssertEqual(result?.normalizedName, "name")
    }

    func testRejectsOnlyOne() {
        let result = Plural.asPlural(["one": "1 clip"], key: "name", namespace: "namespace")
        XCTAssertNil(result)
    }

    func testRejectsOnlyOther() {
        let result = Plural.asPlural(["other": "%lu clips"], key: "name", namespace: "namespace")
        XCTAssertNil(result)
    }

    func testRejectsBadTypes() {
        let result = Plural.asPlural(1, key: "name", namespace: "namespace")
        XCTAssertNil(result)
        let result2 = Plural.asPlural("test", key: "name", namespace: "namespace")
        XCTAssertNil(result2)
    }

    func testRejectsMissingInterpolations() {
        let result = Plural(key: "test", namespace: "namespace", comment: nil, other: "missing", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertNil(result)
    }

    // MARK: - Swift conversation

    func testSwiftSimpleCase() {
        let plural = Plural(key: "name", namespace: "namespace", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toSwiftCode(visibility: .internal), """
internal static func name(count: Int) -> String { return String.localizedStringWithFormat(_name, count) }
private static let _name = Foundation.NSLocalizedString("namespace.name", bundle: __bundle, comment: "")
""")
    }

    func testSwiftWithComment() {
        let plural = Plural(key: "name", namespace: "namespace", comment: "comment", other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toSwiftCode(visibility: .internal), """
internal static func name(count: Int) -> String { return String.localizedStringWithFormat(_name, count) }
private static let _name = Foundation.NSLocalizedString("namespace.name", bundle: __bundle, comment: "comment")
""")
    }

    func testSwiftVisibility() {
        let plural = Plural(key: "name", namespace: "namespace", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toSwiftCode(visibility: .public), """
public static func name(count: Int) -> String { return String.localizedStringWithFormat(_name, count) }
private static let _name = Foundation.NSLocalizedString("namespace.name", bundle: __bundle, comment: "")
""")
    }

    // MARK: - Objective-C conversation

    func testObjcSimpleCase() {
        let plural = Plural(key: "name", namespace: "namespace", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toObjcCode(visibility: .internal), """
internal static func Namespace_Name(count: Int)) -> String { return namespace.name(count: count) }
""")
    }

    func testObjcVisibility() {
        let plural = Plural(key: "name", namespace: "weird.namespace_with.stuff", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toObjcCode(visibility: .public), """
public static func Weird_Namespace_with_Stuff_Name(count: Int)) -> String { return weird.namespace_with.stuff.name(count: count) }
""")
    }

    func testObjcNamespaceNormalized() {
        let plural = Plural(key: "name", namespace: "weird.namespace_with.stuff", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toObjcCode(visibility: .internal), """
internal static func Weird_Namespace_with_Stuff_Name(count: Int)) -> String { return weird.namespace_with.stuff.name(count: count) }
""")
    }

    // MARK: - XML conversation

    func testXmlSimpleCase() {
        let plural = Plural(key: "name", namespace: "namespace", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toXml(transformation: .standard, index: 0), """
<key>name</key>
<dict>
<key>NSStringLocalizedFormatKey</key>
<string>%#@variable_0@</string>
<key>variable_0</key>
<dict>
<key>NSStringFormatSpecTypeKey</key>
<string>NSStringPluralRuleType</string>
<key>NSStringFormatValueTypeKey</key>
<string>lu</string>
<key>one</key>
<string>1 clip</string>
<key>other</key>
<string>%lu clips</string>
</dict>
</dict>
""")
    }

    func testXmlKeyTranslation() {
        let plural = Plural(key: "name", namespace: "namespace.blah.yay", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toXml(transformation: .key, index: 0), """
<key>name</key>
<dict>
<key>NSStringLocalizedFormatKey</key>
<string>%#@variable_0@</string>
<key>variable_0</key>
<dict>
<key>NSStringFormatSpecTypeKey</key>
<string>NSStringPluralRuleType</string>
<key>NSStringFormatValueTypeKey</key>
<string>lu</string>
<key>one</key>
<string>namespace.blah.yay.name</string>
<key>other</key>
<string>namespace.blah.yay.name</string>
</dict>
</dict>
""")
    }

    func testXmlPseudoTranslation() {
        let plural = Plural(key: "name", namespace: "namespace.blah.yay", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toXml(transformation: .pseudo, index: 0), """
<key>name</key>
<dict>
<key>NSStringLocalizedFormatKey</key>
<string>%#@variable_0@</string>
<key>variable_0</key>
<dict>
<key>NSStringFormatSpecTypeKey</key>
<string>NSStringPluralRuleType</string>
<key>NSStringFormatValueTypeKey</key>
<string>lu</string>
<key>one</key>
<string>1 çļîîîþ</string>
<key>other</key>
<string>%lu çļîîîþš</string>
</dict>
</dict>
""")
    }

    func testXmlIndex() {
        let plural = Plural(key: "name", namespace: "namespace", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)
        XCTAssertEqual(plural?.toXml(transformation: .standard, index: 865), """
<key>name</key>
<dict>
<key>NSStringLocalizedFormatKey</key>
<string>%#@variable_865@</string>
<key>variable_865</key>
<dict>
<key>NSStringFormatSpecTypeKey</key>
<string>NSStringPluralRuleType</string>
<key>NSStringFormatValueTypeKey</key>
<string>lu</string>
<key>one</key>
<string>1 clip</string>
<key>other</key>
<string>%lu clips</string>
</dict>
</dict>
""")
    }

}
