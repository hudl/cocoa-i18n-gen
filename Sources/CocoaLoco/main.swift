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
    Argument<String>("outputFile", description: "The file path to write the generated file"),
    Flag("public", description: "Make the generated file public"),
    Flag("objc", description: "Add Objective-C compatibility"),
    Option<String>("prefix", default: "", description: "Prefix the file, LocalizableStrings struct, and ObjcLocalizableStrings class with a specific string"),
    Option<String>("bundleName", default: "", description: "If you need to load your strings from a specific bundle instead of the bundle that you will include the generated class in")
) { inputFile, outputFile, isPublic, objcSupport, prefix, bundleName in
    let inputURL = URL(fileURLWithPath: inputFile)
    let outputURL = URL(fileURLWithPath: outputFile)
    CocoaLocoCore.run(inputURL: inputURL, outputURL: outputURL, isPublic: isPublic, objcSupport: objcSupport, namePrefix: prefix, bundleName: bundleName)
}

let group = Group()
group.addCommand("generate", generate)
group.run(CocoaLoco.version)
