//
//  main.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/26/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

public struct CocoaLocoCore {
    
    private static let defaultName = "LocalizableStrings"
    
    public static func run(inputURL: URL, outputURL: URL, isPublic: Bool = false, objcSupport: Bool = false, namePrefix: String? = nil, bundleName: String? = nil) {
        let start = Date()
        
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            print("File not found at \(inputURL.path)")
            exit(EXIT_FAILURE)
        }
        
        var isDir : ObjCBool = false
        guard FileManager.default.fileExists(atPath: outputURL.path, isDirectory: &isDir), isDir.boolValue else {
            print("Directory not found at \(outputURL.path)")
            exit(EXIT_FAILURE)
        }
        
        let jsonData: Any
        do {
            let data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        } catch {
            print("Something went wrong parsing the input file - \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        }
        
        guard let jsonResult = jsonData as? [String: Any] else {
            print("Input file was not in the expected JSON object format")
            exit(EXIT_FAILURE)
        }
        
        let visibility: Visibility = isPublic ? .public : .internal
        let initialName: String
        if let namePrefix = namePrefix {
            initialName = "\(namePrefix)\(defaultName)"
        } else {
            initialName = defaultName
        }
        
        let namespace = LocalizationNamespace.parseValue(jsonResult, fullNamespace: initialName, key: defaultName)
        let swiftOutputFile = SwiftOutputFile(namespace: namespace)
        let baseStringsDictFile = StringsDictOutputFile(namespace: namespace)

        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            try swiftOutputFile.write(to: outputURL.appendingPathComponent(initialName).appendingPathExtension("swift"),
                                      objc: objcSupport,
                                      isPublic: isPublic,
                                      visibility: visibility)
            try [
                ("Base", Plural.Transformation.standard),
                ("en-JP", Plural.Transformation.key),
                ("en-RW", Plural.Transformation.pseudo)
            ].forEach { (name, transformation) in
                let baseURL = outputURL.appendingPathComponent("\(name).lproj")
                try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true, attributes: nil)
                try baseStringsDictFile.write(to: baseURL.appendingPathComponent("Localizable.stringsdict"), transformation: transformation)
            }
        } catch {
            print("There was an error writing the output file - \(error)")
            exit(EXIT_FAILURE)
        }
        
        print("Execution time - \(Date().timeIntervalSince(start))")
    }
    
}
