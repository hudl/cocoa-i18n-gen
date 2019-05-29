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
        
        // TODO add swift AND typescript support.
        // TODO plural support
        
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
        let namespace = LocalizationNamespace.parseValue(jsonResult, prefix: defaultName, key: defaultName)
        let outputFile = SwiftOutputFile(namespace: namespace)

        do {
            try outputFile.write(to: outputURL, objc: objcSupport, isPublic: isPublic, visibility: visibility)
        } catch {
            print("There was an error writing the output file - \(error)")
            exit(EXIT_FAILURE)
        }
        
        print("Execution time - \(Date().timeIntervalSince(start))")
    }
    
}
