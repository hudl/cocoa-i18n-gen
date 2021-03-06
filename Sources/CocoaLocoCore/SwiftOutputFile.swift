//
//  SwiftOutputFile.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

class SwiftOutputFile {

    private let namespace: LocalizationNamespace

    init(namespace: LocalizationNamespace) {
        self.namespace = namespace
    }

    func write(to url: URL, objc: Bool, visibility: Visibility, prefix: String = "", bundleName: String? = nil) throws {
        let bundleRef: String
        if let bundleName = bundleName, !bundleName.isEmpty {
            bundleRef = ".\(bundleName)"
        } else {
            bundleRef = "(for: BundleReference.self)"
        }
        var objcContent = ""
        if objc {
            objcContent = """

            // Compatibility layer so the strings can be used in ObjC
            // This code should only be available to Objective-C, not Swift, hence to obsoleted attribute.
            @objcMembers
            @available(swift, obsoleted: 1.0, message: "Use \(prefix)LocalizableStrings instead")
            \(visibility.rawValue) class \(prefix)ObjCLocalizableStrings: Foundation.NSObject {
            \(namespace.toObjcCode(visibility: visibility, baseName: namespace.name))
            }

            """
        }
        let content = """
        // This file is autogenerated, do not modify it. Modify the strings in LocalizableStrings.json instead

        import Foundation
        private let __bundle = Foundation.Bundle\(bundleRef)
        \(namespace.toSwiftCode(indent: 2, visibility: visibility))
        \(objcContent)
        private class BundleReference {}
        """

        try content.write(to: url, atomically: true, encoding: .utf8)
    }

}
