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
    let enums: [LocalizationNamespace]
    let strings: [LocalizedString]
    let plurals: [Plural]
    
    static func parseValue(_ dict: [String: Any], fullNamespace: String, key: String) -> LocalizationNamespace {
        var enums = [LocalizationNamespace]()
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
                enums.append(parseValue(dictValue, fullNamespace: fullNamespace, key: normalizedName))
            } else {
                fatalError("RIP")
            }
        }
        
        return LocalizationNamespace(normalizedName: key, enums: enums, strings: strings, plurals: plurals)
    }
    
    func toSwiftCode(indent: Int, visibility: Visibility) -> String {
        var code = "\(visibility.rawValue) enum \(normalizedName) {\n"
        code += enums.toCode(indent: indent, { $0.toSwiftCode(indent: indent + 2, visibility: visibility) })
        code += plurals.toCode(indent: indent, { $0.toSwiftCode(indent: indent + 2, visibility: visibility, swiftEnum: self) })
        code += strings.toCode(indent: indent, { $0.toSwiftCode(indent: indent + 2, visibility: visibility, swiftEnum: self) })
        code += "}".indented(by: indent)
        return code
    }
    
    func toObjcCode(visibility: Visibility) -> String {
        var code = enums
            .sorted(by: { $0.normalizedName < $1.normalizedName })
            .map { $0.toObjcCode(visibility: visibility) }
            .joined()
        code += strings
            .sorted(by: { $0.normalizedName < $1.normalizedName })
            .map { $0.toObjcCode(visibility: visibility) }
            .joined(separator: "\n")
        if !strings.isEmpty {
            code += "\n"
        }
        return code
    }
}
