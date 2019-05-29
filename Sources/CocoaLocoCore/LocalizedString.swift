//
//  LocalizedString.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

struct LocalizedString {
    let key: String
    let fullNamespace: String
    let value: String
    let comment: String?
    let arguments: [Argument]
    
    func toSwiftCode(indent: Int, visibility: Visibility, swiftEnum: LocalizationNamespace) -> String {
        let privateVal = "\(swiftEnum.name)._\(key)"
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
        
        let keyWithoutRootNamespace = fullNamespace.split(separator: ".").dropFirst().joined(separator: ".")

        // TODO need to find a way to indent each line
        let code = #"""
        \#(visibility.rawValue) static func \#(key)(\#(arguments.asInput)) -> String { return \#(body) }
        private static let _\#(key) = Foundation.NSLocalizedString("\#(keyWithoutRootNamespace)", bundle: __bundle, value: "\#(newValue)", comment: "\#(comment ?? "")")
        """#
        return code
    }
    
    func toObjcCode(visibility: Visibility) -> String {
        let chunks = fullNamespace.split(separator: ".")
        let name = chunks.dropFirst().map { String($0).capitalizingFirstLetter() }.joined(separator: "_")
        let body = "return \(fullNamespace)(\(arguments.asInvocation))"
        return "\(visibility.rawValue) static func \(name)(\(arguments.asInput)) -> String { \(body) }".indented(by: 2)
    }
}
