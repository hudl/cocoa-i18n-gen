//
//  BenchmarkTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 6/5/19.
//

import Foundation
import XCTest
import CocoaLocoCore

class BenchmarkTests: XCTestCase {

    private var tempURL: URL!
    private let inputURL = Bundle(for: BenchmarkTests.self).url(forResource: "LocalizableStrings", withExtension: "json")!

    override func setUp() {
        super.setUp()
        tempURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                      isDirectory: true).appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempURL)
    }

    func testSwiftOnly() {
        measure {
            try? CocoaLocoCore.run(inputURL: inputURL, outputURL: tempURL)
        }
    }

    func testObjcCompat() {
        measure {
            try? CocoaLocoCore.run(inputURL: inputURL, outputURL: tempURL, objcSupport: true)
        }
    }

}
