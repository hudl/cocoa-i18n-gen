//
//  StringsDictOutputFile.swift
//  CocoaLocoCore
//
//  Created by Brian Clymer on 5/29/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

class StringsDictOutputFile {

    private let namespace: LocalizationNamespace

    init(namespace: LocalizationNamespace) {
        self.namespace = namespace
    }

    func write(to url: URL, transformation: Plural.Transformation) throws {
        let plurals = StringsDictOutputFile
            .allPlurals(namespace: namespace)
            .sorted(by: { $0.normalizedName < $1.normalizedName })
            .enumerated()
            .map { $1.toXml(transformation: transformation, index: $0) }
            .joined(separator: "\n")
        let content = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        \(plurals)
        </dict>
        </plist>
        """
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    private static func allPlurals(namespace: LocalizationNamespace) -> [Plural] {
        let rootPlurals = namespace.plurals
        let nestedPlurals = namespace.namespaces.flatMap { allPlurals(namespace: $0) }
        return rootPlurals + nestedPlurals
    }

}
