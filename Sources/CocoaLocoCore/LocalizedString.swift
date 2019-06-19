//
//  LocalizedString.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

struct LocalizedString: CodeGeneratable {
    let key: String
    let swiftKey: String
    let swiftFullFunc: String
    let value: String
    let prefix: String
    let comment: String?
    let arguments: [Argument]
    let normalizedName: String
    
    init(key: String,
         namespace: String?,
         value: String,
         prefix: String,
         comment: String?,
         arguments: [Argument]) {
        self.key = key
        self.value = value
        self.prefix = prefix
        self.comment = comment
        self.arguments = arguments
        self.normalizedName = normalizeName(rawName: key)
        self.swiftKey = joinedNamespace(part1: namespace, part2: key)
        self.swiftFullFunc = joinedNamespace(part1: namespace, part2: normalizedName)
    }

    func toSwiftCode(visibility: Visibility, swiftEnum: LocalizationNamespace) -> String {
        let privateVal = "\(swiftEnum.normalizedName)._\(normalizedName)"
        let body: String
        let newValue: String
        if !arguments.isEmpty {
            body = "String.localizedStringWithFormat(\(privateVal), \(arguments.asFormatting))"
            // This will take "Hello {firstName} welcome to {something}" with "Hello %@ welcome to %@"
            // If there are args with the names "firstName" and "something".
            newValue = arguments.reduce(value, { (result, arg) -> String in
                return result.replacingOccurrences(of: "{\(arg.name)}", with: arg.type.interpolatedString)
            })
        } else {
            body = privateVal
            newValue = value
        }

        let tableName = prefix.isEmpty ? "" : #", tableName: "\#(prefix)Localizable""#
        let code = """
        \(visibility.rawValue) static func \(normalizedName)(\(arguments.asInput)) -> String { return \(body) }
        private static let _\(normalizedName) = Foundation.NSLocalizedString("\(swiftKey)"\(tableName), bundle: __bundle, value: "\(newValue)", comment: "\(comment ?? "")")
        """
        return code
    }

    func toObjcCode(visibility: Visibility, baseName: String) -> String {
        let name = swiftFullFunc
            .split(separator: ".")
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: "_")
        let body = "return \(baseName).\(swiftFullFunc)(\(arguments.asInvocation))"
        return "\(visibility.rawValue) static func \(name)(\(arguments.asInput)) -> String { \(body) }"
    }

    static func asLocalizedString(key: String, namespace: String?, prefix: String, value: Any) -> LocalizedString? {
        if let strValue = value as? String {
            return LocalizedString(key: key,
                                   namespace: namespace,
                                   value: strValue,
                                   prefix: prefix,
                                   comment: nil,
                                   arguments: [])
        } else if let dictValue = value as? [String: Any], let strValue = dictValue["value"] as? String {
            let arguments = Argument.parseArgs(strValue: strValue, arguments: dictValue["arguments"] as? [String: String])
            return LocalizedString(key: key,
                                   namespace: namespace,
                                   value: strValue,
                                   prefix: prefix,
                                   comment: dictValue["comment"] as? String,
                                   arguments: arguments)
        }
        return nil
    }

}
