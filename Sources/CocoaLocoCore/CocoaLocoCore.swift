//
//  main.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/26/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

public enum CocoaLocoError: Error {
    case inputFileMissing
    case outputPathIsFile
    case inputFileNotJson(error: Error)
    case inputFileNotDictionary
    case fileWrite(error: Error)
}

public struct CocoaLocoCore {

    private static let defaultName = "LocalizableStrings"

    public static func run(inputURL: URL, outputURL: URL, isPublic: Bool = false, objcSupport: Bool = false, namePrefix: String = "", bundleName: String? = nil) throws {

        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            throw CocoaLocoError.inputFileMissing
        }

        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: outputURL.path, isDirectory: &isDir) && !isDir.boolValue {
            // This only happens if it exists, but it's not a directory.
            // It is valid for it to either not exist at all, or exist as a directory,
            // it just can't exist as a file.
            throw CocoaLocoError.outputPathIsFile
        }

        let jsonData: Any
        do {
            let data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        } catch {
            throw CocoaLocoError.inputFileNotJson(error: error)
        }

        guard let jsonResult = jsonData as? [String: Any] else {
            throw CocoaLocoError.inputFileNotDictionary
        }

        let visibility: Visibility = isPublic ? .public : .internal
        let initialName: String = "\(namePrefix)\(defaultName)"
        let namespace = LocalizationNamespace.parseValue(jsonResult,
                                                         namespace: nil,
                                                         normalizedName: initialName,
                                                         prefix: namePrefix)
        let swiftOutputFile = SwiftOutputFile(namespace: namespace)
        let baseStringsDictFile = StringsDictOutputFile(namespace: namespace)

        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            try swiftOutputFile.write(to: outputURL.appendingPathComponent(initialName).appendingPathExtension("swift"),
                                      objc: objcSupport,
                                      visibility: visibility,
                                      prefix: namePrefix,
                                      bundleName: bundleName)
            try [
                ("Base", Plural.Transformation.standard),
                ("en-JP", Plural.Transformation.key),
                ("en-RW", Plural.Transformation.pseudo)
            ].forEach { (name, transformation) in
                let baseURL = outputURL.appendingPathComponent("\(name).lproj")
                try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true, attributes: nil)
                let fileName = "\(namePrefix)Localizable.stringsdict"
                let finalURL = baseURL.appendingPathComponent(fileName)
                try baseStringsDictFile.write(to: finalURL, transformation: transformation)
            }
        } catch {
            throw CocoaLocoError.fileWrite(error: error)
        }
    }

}
