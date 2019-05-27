//
//  LocalizationNamespace.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

struct LocalizationNamespace {
    
    let name: String
    let enums: [LocalizationNamespace]
    let strings: [LocalizedString]
    
    static func parseValue(_ dict: [String: Any], prefix: String, key: String) -> LocalizationNamespace {
        var enums = [LocalizationNamespace]()
        var strings = [LocalizedString]()
        dict.forEach { key, value in
            let key = key
                .split(separator: "-")
                .enumerated()
                .map { index, str -> String in
                    if index > 0 {
                        return String(str).capitalizingFirstLetter()
                    } else {
                        return String(str)
                    }
                }
                .joined()
            let nextPrefix = "\(prefix).\(key)"
            if let strValue = value as? String {
                // it's a value by itself
                strings.append(LocalizedString(key: key,
                                               prefix: nextPrefix,
                                               value: strValue,
                                               comment: nil,
                                               arguments: []))
            } else if let dictValue = value as? [String :Any] {
                if let strValue = dictValue["value"] as? String {
                    // it's a value / comment pair
                    let arguments = Argument.parseArgs(strValue: strValue, arguments: dictValue["arguments"] as? [String: String])
                    strings.append(LocalizedString(key: key,
                                                   prefix: nextPrefix,
                                                   value: strValue,
                                                   comment: dictValue["comment"] as? String,
                                                   arguments: arguments))
                } else {
                    // it's a namespace, parse it again!
                    enums.append(parseValue(dictValue, prefix: nextPrefix, key: key))
                }
            } else {
                fatalError("RIP")
            }
        }
        
        return LocalizationNamespace(name: key, enums: enums, strings: strings)
    }
    
    func toSwiftCode(indent: Int) -> String {
        var code = "internal enum \(name) {\n"
        code += enums
            .sorted(by: { $0.name < $1.name })
            .map { $0.toSwiftCode(indent: indent + 2) }
            .map { $0.indented(by: indent + 2) }
            .joined(separator: "\n")
        if !enums.isEmpty {
            code += "\n"
        }
        code += strings
            .sorted(by: { $0.key < $1.key })
            .map { $0.toSwiftCode(indent: indent + 2, swiftEnum: self) }
            .joined(separator: "\n")
        if !strings.isEmpty {
            code += "\n"
        }
        code += "}".indented(by: indent)
        return code
    }
    
    func toObjcCode() -> String {
        var code = enums
            .sorted(by: { $0.name < $1.name })
            .map { $0.toObjcCode() }
            .joined()
        code += strings
            .sorted(by: { $0.key < $1.key })
            .map { $0.toObjcCode() }
            .joined(separator: "\n")
        if !strings.isEmpty {
            code += "\n"
        }
        return code
    }
}
