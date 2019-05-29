//
//  main.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/26/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

public struct CocoaLocoCore {
    
    public static func run(inputURL: URL, outputURL: URL, isPublic: Bool = false, objcSupport: Bool = false, namePrefix: String? = nil, bundleName: String? = nil) {
        let start = Date()
        
        // TODO add swift AND typescript support.
        // TODO make objective-c support optional.
        // TODO add commander + all the supported commands for the old tool.
        // TODO plural support
        
        let data = try! Data(contentsOf: inputURL, options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        
        let namespace = LocalizationNamespace.parseValue(jsonResult, prefix: "LocalizableStrings", key: "LocalizableStrings")
        
        let outputFile = SwiftOutputFile(namespace: namespace)
        try! outputFile.write(to: outputURL, objc: objcSupport, isPublic: isPublic)
        
        print("Execution time - \(Date().timeIntervalSince(start))")
    }
    
}
