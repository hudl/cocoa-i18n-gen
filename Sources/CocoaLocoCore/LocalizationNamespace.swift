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
    
    static func parseValue(_ dict: [String: Any], fullNamespace: String?, normalizedName: String) -> LocalizationNamespace {
        var namespaces = [LocalizationNamespace]()
        var strings = [LocalizedString]()
        var plurals = [Plural]()
        
        dict.forEach { key, value in
            let normalizedName = normalizeName(rawName: key)
            let nextNamespace: String
            if let fullNamespace = fullNamespace {
                nextNamespace = "\(fullNamespace).\(normalizedName)"
            } else {
                nextNamespace = normalizedName
            }
            if let plural = Plural.asPlural(value, normalizedName: normalizedName, fullNamespace: nextNamespace) {
                plurals.append(plural)
            } else if let string = LocalizedString.asLocalizedString(normalizedName: normalizedName, fullNamespace: nextNamespace, value: value) {
                strings.append(string)
            } else if let dictValue = value as? [String :Any] {
                namespaces.append(parseValue(dictValue, fullNamespace: nextNamespace, normalizedName: normalizedName))
            } else {
                fatalError("RIP")
            }
        }
        
        return LocalizationNamespace(normalizedName: normalizedName, namespaces: namespaces, strings: strings, plurals: plurals)
    }
    
    func toSwiftCode(indent: Int, visibility: Visibility) -> String {
        return """
        \(visibility.rawValue) enum \(normalizedName) {
        \(namespaces.toCode(indent: indent, { $0.toSwiftCode(indent: 2, visibility: visibility) }))
        \(plurals.toCode(indent: indent, { $0.toSwiftCode(visibility: visibility, swiftEnum: self) }))
        \(strings.toCode(indent: indent, { $0.toSwiftCode(visibility: visibility, swiftEnum: self) }))
        }
        """
    }
    
    func toObjcCode(visibility: Visibility, baseName: String) -> String {
        return """
        \(namespaces.toCode(indent: 0, { $0.toObjcCode(visibility: visibility, baseName: baseName) }))
        \(strings.toCode(indent: 2, { $0.toObjcCode(visibility: visibility, baseName: baseName) }))
        """
    }
}
