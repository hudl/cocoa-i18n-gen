//
//  LocalizedString.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

struct LocalizedString: CodeGeneratable {
    let normalizedName: String
    let fullNamespace: String
    let value: String
    let comment: String?
    let arguments: [Argument]

    func toSwiftCode(visibility: Visibility, swiftEnum: LocalizationNamespace) -> String {
        let privateVal = "\(swiftEnum.normalizedName)._\(normalizedName)"
        let body: String
        let newValue: String
        if !arguments.isEmpty {
            body = "String.localizedStringWithFormat(\(privateVal), \(arguments.asFormatting))"
            // This will take "Hello {firstName} welcome to {something}" with "Hello %@ welcome to %@"
            // If there are args with the names "firstName" and "something".
            newValue = arguments.reduce(value, { (result, arg) -> String in
                return result.replacingOccurrences(of: "{\(arg.name)}", with: "%@")
            })
        } else {
            body = privateVal
            newValue = value
        }

        let code = """
        \(visibility.rawValue) static func \(normalizedName)(\(arguments.asInput)) -> String { return \(body) }
        private static let _\(normalizedName) = Foundation.NSLocalizedString("\(fullNamespace)", bundle: __bundle, value: "\(newValue)", comment: "\(comment ?? "")")
        """
        return code
    }

    func toObjcCode(visibility: Visibility, baseName: String) -> String {
        let name = fullNamespace
            .split(separator: ".")
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: "_")
        let body = "return \(baseName).\(fullNamespace)(\(arguments.asInvocation))"
        return "\(visibility.rawValue) static func \(name)(\(arguments.asInput)) -> String { \(body) }"
    }

    static func asLocalizedString(normalizedName: String, fullNamespace: String, value: Any) -> LocalizedString? {
        if let strValue = value as? String {
            return LocalizedString(normalizedName: normalizedName,
                                   fullNamespace: fullNamespace,
                                   value: strValue,
                                   comment: nil,
                                   arguments: [])
        } else if let dictValue = value as? [String: Any], let strValue = dictValue["value"] as? String {
            let arguments = Argument.parseArgs(strValue: strValue, arguments: dictValue["arguments"] as? [String: String])
            return LocalizedString(normalizedName: normalizedName,
                                   fullNamespace: fullNamespace,
                                   value: strValue,
                                   comment: dictValue["comment"] as? String,
                                   arguments: arguments)
        }
        return nil
    }

}
