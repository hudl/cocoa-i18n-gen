//
//  CocoaLocoCoreTests.swift
//  CocoaLocoTests
//
//  Created by Brian Clymer on 6/6/19.
//

import Foundation
import XCTest
import CocoaLocoCore

class CocoaLocoCoreTests: XCTestCase {

    private var outputURL: URL!
    private let inputURL = Bundle(for: CocoaLocoCoreTests.self).url(forResource: "LocalizableStrings", withExtension: "json")!
    private let nonJsonInputURL = Bundle(for: CocoaLocoCoreTests.self).url(forResource: "NotJson", withExtension: "png")!
    private let nonDictionaryInputURL = Bundle(for: CocoaLocoCoreTests.self).url(forResource: "NotDictionary", withExtension: "json")!

    override func setUp() {
        super.setUp()
        outputURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                      isDirectory: true).appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: outputURL)
    }

    func testBadInputFilePath() {
        checkError(try CocoaLocoCore.run(inputURL: URL(fileURLWithPath: "badPath"), outputURL: outputURL), errorType: .inputFileMissing)
    }

    func testOutputPathIsDirectory() {
        checkError(try CocoaLocoCore.run(inputURL: inputURL, outputURL: inputURL), errorType: .outputPathIsFile)
    }

    func testInputFileIsNotJson() {
        checkError(try CocoaLocoCore.run(inputURL: nonJsonInputURL, outputURL: outputURL), errorType: .inputFileNotJson(error: CocoaLocoError.inputFileMissing))
    }

    func testInputFileIsJsonButNotDictionary() {
        checkError(try CocoaLocoCore.run(inputURL: nonDictionaryInputURL, outputURL: outputURL), errorType: .inputFileNotDictionary)
    }

    func testCreatesAllFourFiles() {
        try? CocoaLocoCore.run(inputURL: inputURL, outputURL: outputURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.appendingPathComponent("LocalizableStrings.swift").path))
        ["Base", "en-JP", "en-RW"].forEach { locale in
            XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL
                .appendingPathComponent("\(locale).lproj")
                .appendingPathComponent("Localizable.stringsdict")
                .path))
        }
    }

    func testHandlesNoWritePermissions() {
        // TODO does this only work on Catalina? What's another read only directory on all macOS versions?
        let systemURL = URL(fileURLWithPath: "/usr/bin")
        checkError(try CocoaLocoCore.run(inputURL: inputURL, outputURL: systemURL), errorType: .fileWrite(error: CocoaLocoError.inputFileMissing))
    }

    func testHandlesFilePrefixNames() {
        try? CocoaLocoCore.run(inputURL: inputURL, outputURL: outputURL, namePrefix: "Base")
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.appendingPathComponent("BaseLocalizableStrings.swift").path))
        ["Base", "en-JP", "en-RW"].forEach { locale in
            XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL
                .appendingPathComponent("\(locale).lproj")
                .appendingPathComponent("BaseLocalizable.stringsdict")
                .path))
        }
    }

    private func checkError<T>(_ expression: @autoclosure () throws -> T, errorType: CocoaLocoError) {
        XCTAssertThrowsError(try expression()) { error in
            XCTAssertEqual(error as? CocoaLocoError, errorType)
        }
    }

}

extension CocoaLocoError: Equatable {
    public static func == (lhs: CocoaLocoError, rhs: CocoaLocoError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}
