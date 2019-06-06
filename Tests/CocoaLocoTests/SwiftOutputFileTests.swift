//
//  SwiftOutputFileTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 6/5/19.
//

import Foundation
import XCTest
@testable import CocoaLocoCore

class SwiftOutputFileTests: XCTestCase {
    
    private var tempURL: URL!
    
    override func setUp() {
        super.setUp()
        tempURL = URL(fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: true).appendingPathComponent(UUID().uuidString)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    func testWriteSimple() {
        try? SwiftOutputFile(namespace: exampleNamespace).write(to: tempURL, objc: false, visibility: .internal)
        XCTAssertEqual(readTemp(), """
// This file is autogenerated, do not modify it. Modify the strings in LocalizableStrings.json instead

import Foundation
private let __bundle = Foundation.Bundle(for: BundleReference.self)
internal enum testName {
}

private class BundleReference {}
""")
    }
    
    func testWriteObjc() {
        try? SwiftOutputFile(namespace: exampleNamespace).write(to: tempURL, objc: true, visibility: .internal)
        XCTAssertEqual(readTemp(), """
// This file is autogenerated, do not modify it. Modify the strings in LocalizableStrings.json instead

import Foundation
private let __bundle = Foundation.Bundle(for: BundleReference.self)
internal enum testName {
}

// Compatibility layer so the strings can be used in ObjC
// This code should only be available to Objective-C, not Swift, hence to obsoleted attribute.
@objcMembers
@available(swift, obsoleted: 1.0, message: "Use LocalizableStrings instead")
internal class ObjCLocalizableStrings: Foundation.NSObject {

}

private class BundleReference {}
""")
    }
    
    func testWritePublic() {
        try? SwiftOutputFile(namespace: exampleNamespace).write(to: tempURL, objc: false, visibility: .public)
        XCTAssertEqual(readTemp(), """
// This file is autogenerated, do not modify it. Modify the strings in LocalizableStrings.json instead

import Foundation
private let __bundle = Foundation.Bundle(for: BundleReference.self)
public enum testName {
}

private class BundleReference {}
""")
    }
    
    func testWriteWithPrefix() {
        try? SwiftOutputFile(namespace: exampleNamespace).write(to: tempURL, objc: true, visibility: .internal, prefix: "Base")
        XCTAssertEqual(readTemp(), """
// This file is autogenerated, do not modify it. Modify the strings in LocalizableStrings.json instead

import Foundation
private let __bundle = Foundation.Bundle(for: BundleReference.self)
internal enum testName {
}

// Compatibility layer so the strings can be used in ObjC
// This code should only be available to Objective-C, not Swift, hence to obsoleted attribute.
@objcMembers
@available(swift, obsoleted: 1.0, message: "Use BaseLocalizableStrings instead")
internal class BaseObjCLocalizableStrings: Foundation.NSObject {

}

private class BundleReference {}
""")
    }
    
    func testWriteWithBundleName() {
        try? SwiftOutputFile(namespace: exampleNamespace).write(to: tempURL, objc: false, visibility: .internal, bundleName: "CoolBundle")
        XCTAssertEqual(readTemp(), """
// This file is autogenerated, do not modify it. Modify the strings in LocalizableStrings.json instead

import Foundation
private let __bundle = Foundation.Bundle.CoolBundle
internal enum testName {
}

private class BundleReference {}
""")
    }
    
    private func readTemp() -> String? {
        return try? String(contentsOf: tempURL)
    }
    
}

private let exampleNamespace = LocalizationNamespace(normalizedName: "testName",
                                                     namespaces: [],
                                                     strings: [],
                                                     plurals: [])
