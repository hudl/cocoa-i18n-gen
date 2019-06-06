//
//  main.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/26/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation
import CocoaLocoCore
import Commander

let generate = command(
    Argument<String>("inputFile", description: "The json file to parse"),
    Argument<String>("outputFile", description: "The directory to write the generated files in"),
    Flag("public", description: "Make the generated file public"),
    Flag("objc", description: "Add Objective-C compatibility"),
    Option<String>("prefix", default: "", description: "Prefix the file, LocalizableStrings struct, and ObjcLocalizableStrings class with a specific string"),
    Option<String>("bundleName", default: "", description: "If you need to load your strings from a specific bundle instead of the bundle that you will include the generated class in")
) { inputFile, outputFile, isPublic, objcSupport, prefix, bundleName in
    let inputURL = URL(fileURLWithPath: inputFile)
    let outputURL = URL(fileURLWithPath: outputFile)
    let start = Date()
    var result = EXIT_FAILURE
    do {
        try CocoaLocoCore.run(inputURL: inputURL, outputURL: outputURL, isPublic: isPublic, objcSupport: objcSupport, namePrefix: prefix, bundleName: bundleName)
        result = EXIT_SUCCESS
        print("Execution time - \(Date().timeIntervalSince(start))")
    } catch CocoaLocoError.inputFileMissing {
        print("File not found at \(inputURL.path)")
    } catch CocoaLocoError.outputPathIsFile {
        print("Path at \(outputURL.path) is already a file. It needs to be a directory")
    } catch CocoaLocoError.inputFileNotJson(let subError) {
        print("Something went wrong parsing the input file - \(subError.localizedDescription)")
    } catch CocoaLocoError.inputFileNotDictionary {
        print("File at \(inputURL.path) is not in the expected dictionary JSON format")
    } catch CocoaLocoError.fileWrite(let subError) {
        print("There was an error writing the output file - \(subError.localizedDescription)")
    } catch {
        print("An unknown error occured - \(error.localizedDescription)")
    }
    exit(result)
}

let group = Group()
group.addCommand("generate", generate)
group.run(CocoaLoco.version)
