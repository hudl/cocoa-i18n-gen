//
//  StringsDictOutputFileTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 6/5/19.
//

import Foundation
import XCTest
@testable import CocoaLocoCore

class StringsDictOutputFileTests: XCTestCase {

    private var tempURL: URL!

    override func setUp() {
        super.setUp()
        tempURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                      isDirectory: true).appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempURL)
    }

    func testWriteStandard() {
        try? StringsDictOutputFile(namespace: exampleNamespace).write(to: tempURL, transformation: .standard)
        XCTAssertEqual(readTemp(), """
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
<key>one</key>
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
</dict>
</plist>
""")
    }

    func testWriteKeys() {
        try? StringsDictOutputFile(namespace: exampleNamespace).write(to: tempURL, transformation: .key)
        XCTAssertEqual(readTemp(), """
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
<key>one</key>
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
<string>oneName</string>
<key>other</key>
<string>oneName</string>
</dict>
</dict>
</dict>
</plist>
""")
    }

    func testWritePseudo() {
        try? StringsDictOutputFile(namespace: exampleNamespace).write(to: tempURL, transformation: .pseudo)
        XCTAssertEqual(readTemp(), """
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
<key>one</key>
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
</dict>
</plist>
""")
    }

    private func readTemp() -> String? {
        return try? String(contentsOf: tempURL)
    }

}

private let examplePlurals = [
    Plural(normalizedName: "one", fullNamespace: "oneName", prefix: "", comment: nil, other: "%lu clips", one: "1 clip", zero: nil, two: nil, few: nil, many: nil)!
]
private let exampleNamespace = LocalizationNamespace(normalizedName: "testName",
                                                     namespaces: [],
                                                     strings: [],
                                                     plurals: examplePlurals)
