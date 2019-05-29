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
    
    static func parseValue(_ dict: [String: Any], fullNamespace: String, key: String) -> LocalizationNamespace {
        var namespaces = [LocalizationNamespace]()
        var strings = [LocalizedString]()
        var plurals = [Plural]()
        
        dict.forEach { key, value in
            let normalizedName = normalizeName(rawName: key)
            let fullNamespace = "\(fullNamespace).\(normalizedName)"
            if let plural = Plural.asPlural(value, normalizedName: normalizedName, fullNamespace: fullNamespace) {
                plurals.append(plural)
            } else if let string = LocalizedString.asLocalizedString(normalizedName: normalizedName, fullNamespace: fullNamespace, value: value) {
                strings.append(string)
            } else if let dictValue = value as? [String :Any] {
                namespaces.append(parseValue(dictValue, fullNamespace: fullNamespace, key: normalizedName))
            } else {
                fatalError("RIP")
            }
        }
        
        return LocalizationNamespace(normalizedName: key, namespaces: namespaces, strings: strings, plurals: plurals)
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
    
    func toObjcCode(visibility: Visibility) -> String {
        return """
        \(namespaces.toCode(indent: 0, { $0.toObjcCode(visibility: visibility) }))
        \(strings.toCode(indent: 2, { $0.toObjcCode(visibility: visibility) }))
        """
    }
}
