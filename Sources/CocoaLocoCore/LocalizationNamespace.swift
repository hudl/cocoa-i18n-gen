//
//  LocalizationNamespace.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

struct LocalizationNamespace: CodeGeneratable {

    let normalizedName: String
    let namespaces: [LocalizationNamespace]
    let strings: [LocalizedString]
    let plurals: [Plural]

    static func parseValue(_ dict: [String: Any], namespace: String?, normalizedName: String, prefix: String) -> LocalizationNamespace {
        var namespaces = [LocalizationNamespace]()
        var strings = [LocalizedString]()
        var plurals = [Plural]()

        dict.forEach { key, value in
            let normalizedName = normalizeName(rawName: key)
            if let plural = Plural.asPlural(value, key: key, namespace: namespace, prefix: prefix) {
                plurals.append(plural)
            } else if let string = LocalizedString.asLocalizedString(key: key, namespace: namespace, prefix: prefix, value: value) {
                strings.append(string)
            } else if let dictValue = value as? [String: Any] {
                let nextNamespace = joinedNamespace(part1: namespace, part2: normalizedName)
                namespaces.append(parseValue(dictValue, namespace: nextNamespace, normalizedName: normalizedName, prefix: prefix))
            } else {
                fatalError("RIP")
            }
        }

        return LocalizationNamespace(normalizedName: normalizedName, namespaces: namespaces, strings: strings, plurals: plurals)
    }

    func toSwiftCode(indent: Int, visibility: Visibility) -> String {
        // not using multiline strings so I can control when newlines are added
        var content = ""
        content += "\(visibility.rawValue) enum \(normalizedName) {\n"
        if !namespaces.isEmpty {
            content += namespaces.toCode(indent: indent, { $0.toSwiftCode(indent: 2, visibility: visibility) })
            content += "\n"
        }
        if !plurals.isEmpty {
            content += plurals.toCode(indent: indent, { $0.toSwiftCode(visibility: visibility) })
            content += "\n"
        }
        if !strings.isEmpty {
            content += strings.toCode(indent: indent, { $0.toSwiftCode(visibility: visibility, swiftEnum: self) })
            content += "\n"
        }
        content += "}"
        return content
    }

    func toObjcCode(visibility: Visibility, baseName: String) -> String {
        // not using multiline strings so I can control when newlines are added
        var content = ""
        if !namespaces.isEmpty {
            content += namespaces.toCode(indent: 0, { $0.toObjcCode(visibility: visibility, baseName: baseName) })
        }
        if !namespaces.isEmpty && !strings.isEmpty && !content.isEmpty {
            content += "\n"
        }
        if !strings.isEmpty {
            content += strings.toCode(indent: 2, { $0.toObjcCode(visibility: visibility, baseName: baseName) })
        }
        return content
    }
}
