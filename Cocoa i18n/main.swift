//
//  main.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/26/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

let start = Date()

// TODO add swift AND typescript support.
// TODO make objective-c support optional.
// TODO add commander + all the supported commands for the old tool.

private extension String {
    func indented(by: Int) -> String {
        return String(repeating: " ", count: by) + self
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    func lowercaseFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}

private struct SwiftEnum {
    let name: String
    let enums: [SwiftEnum]
    let strings: [SwiftLocalizedString]
    
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

private struct SwiftLocalizedString {
    let key: String
    let prefix: String
    let value: String
    let comment: String?
    let arguments: [SwiftArgument]
    
    func toSwiftCode(indent: Int, swiftEnum: SwiftEnum) -> String {
        let args = arguments.sorted(by: { $0.name < $1.name }).map { "\($0.name): \($0.type.type)" }.joined(separator: ", ")
        // TODO obviously garbage variable name
        let args2 = arguments.sorted(by: { $0.name < $1.name }).map { $0.name }.joined(separator: ", ")
        
        let privateVal = "\(swiftEnum.name)._\(key)"
        let body: String
        let newValue: String
        if !arguments.isEmpty {
            body = "String.localizedStringWithFormat(\(privateVal), \(args2))"
            newValue = arguments.reduce(value, { (result, arg) -> String in
                return result.replacingOccurrences(of: "{\(arg.name)}", with: "%@")
            })
        } else {
            body = privateVal
            newValue = value
        }
        
        var code = "internal static func \(key)(\(args)) -> String { return \(body) }".indented(by: indent)
        code += "\n"
        code += "private static let _\(key) = Foundation.NSLocalizedString(\"\(prefix.replacingOccurrences(of: "LocalizableStrings.", with: ""))\", bundle: __bundle, value: \"\(newValue)\", comment: \"\(comment ?? "")\")".indented(by: indent)
        return code
    }
    
    func toObjcCode() -> String {
        let chunks = prefix.split(separator: ".")
        let name = chunks.dropFirst().map { String($0).capitalizingFirstLetter() }.joined(separator: "_")
        let args = arguments.sorted(by: { $0.name < $1.name }).map { "\($0.name): \($0.type.type)" }.joined(separator: ", ")
        let args2 = arguments.sorted(by: { $0.name < $1.name }).map { "\($0.name): \($0.name)" }.joined(separator: ", ")
        return "internal static func \(name)(\(args)) -> String { return \(prefix)(\(args2)) }".indented(by: 2)
    }
}

private struct SwiftArgument {
    let name: String
    let type: SwiftArgumentType
    
    func toSwiftCode(indent: Int) -> String {
        return ""
    }
    
    func toObjcCode() -> String {
        return ""
    }
}

private enum SwiftArgumentType: String {
    case number, string, double
    
    var type: String {
        switch self {
        case .number: return "Int"
        case .string: return "String"
        case .double: return "Double"
        }
    }
}

let url = URL(fileURLWithPath: "/Users/brianclymer/Documents/GitHub/Cocoa i18n/LocalizableStrings.json")
let data = try! Data(contentsOf: url, options: .mappedIfSafe)
let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]

private let pattern = "\\{(.*?)\\}"
private let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])

private func parseArgs(strValue: String, arguments: [String: String]?) -> [SwiftArgument] {
    // Optimization, if it doesn't contain a { char, no need to perform a regex on it.
    guard strValue.contains("{") else { return [] }

    let nsrange = NSRange(strValue.startIndex..<strValue.endIndex, in: strValue)
    let matches = regex.matches(in: strValue, options: [], range: nsrange)
    return matches.compactMap { match -> SwiftArgument? in
        let nsrange = match.range(at: 1)
        if let range = Range(nsrange, in: strValue) {
            let substr = String(strValue[range])
            return SwiftArgument(name: substr,
                                 type: SwiftArgumentType(rawValue: arguments?[substr] ?? "string")!)
        }
        return nil
    }
}

private func parseValue(_ dict: [String: Any], prefix: String, key: String) -> SwiftEnum {
    var enums = [SwiftEnum]()
    var strings = [SwiftLocalizedString]()
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
            strings.append(SwiftLocalizedString(key: key,
                                                prefix: nextPrefix,
                                                value: strValue,
                                                comment: nil,
                                                arguments: []))
        } else if let dictValue = value as? [String :Any] {
            if let strValue = dictValue["value"] as? String {
                // it's a value / comment pair
                let arguments = parseArgs(strValue: strValue, arguments: dictValue["arguments"] as? [String: String])
                strings.append(SwiftLocalizedString(key: key,
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
    
    // TODO should probably not have this specific exception.
    // let name = (key == "LocalizableStrings") ? "LocalizableStrings" : key.lowercaseFirstLetter()
    return SwiftEnum(name: key, enums: enums, strings: strings)
}

private let allValues = parseValue(jsonResult, prefix: "LocalizableStrings", key: "LocalizableStrings")

var content = "// This file is autogenerated, do not modify it. Modify the strings in LocalizableStrings.json instead\n\n"
content += "import Foundation\n"
content += "private let __bundle = Foundation.Bundle(for: BundleReference.self)\n"
content += allValues.toSwiftCode(indent: 0)
content += "\n\n"
content += "// Compatibility layer so the strings can be used in ObjC\n"
content += "// This code should only be available to Objective-C, not Swift, hence to obsoleted attribute.\n"
content += "@objcMembers\n"
content += "@available(swift, obsoleted: 1.0, message: \"Use LocalizableStrings instead\")\n"
content += "internal class ObjCLocalizableStrings: Foundation.NSObject {\n"
content += allValues.toObjcCode()
content += "}\n\n"
content += "private class BundleReference {}"

try! content.write(to: URL(fileURLWithPath: "/Users/brianclymer/Documents/GitHub/Cocoa i18n/LocalizableStrings.swift"), atomically: true, encoding: .utf8)

print("Execution time - \(Date().timeIntervalSince(start))")
