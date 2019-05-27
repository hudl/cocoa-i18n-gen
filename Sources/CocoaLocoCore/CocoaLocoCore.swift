//
//  main.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/26/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

public struct CocoaLocoCore {
    
    public static func run() {
        let start = Date()
        
        // TODO add swift AND typescript support.
        // TODO make objective-c support optional.
        // TODO add commander + all the supported commands for the old tool.
        
        let url = URL(fileURLWithPath: "/Users/brianclymer/Documents/GitHub/cocoa-loco/LocalizableStrings.json")
        let data = try! Data(contentsOf: url, options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        
        let namespace = LocalizationNamespace.parseValue(jsonResult, prefix: "LocalizableStrings", key: "LocalizableStrings")
        
        let outputFile = SwiftOutputFile(namespace: namespace)
        try! outputFile.write(to: URL(fileURLWithPath: "/Users/brianclymer/Documents/GitHub/cocoa-loco/LocalizableStrings.swift"))
        
        print("Execution time - \(Date().timeIntervalSince(start))")
    }
    
}
