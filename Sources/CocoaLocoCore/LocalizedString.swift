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
    let prefix: String
    let value: String
    let comment: String?
    let arguments: [Argument]
    
    func toSwiftCode(indent: Int, visibility: Visibility, swiftEnum: LocalizationNamespace) -> String {
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
        
        var code = "\(visibility.rawValue) static func \(key)(\(args)) -> String { return \(body) }".indented(by: indent)
        code += "\n"
        code += "private static let _\(key) = Foundation.NSLocalizedString(\"\(prefix.replacingOccurrences(of: "LocalizableStrings.", with: ""))\", bundle: __bundle, value: \"\(newValue)\", comment: \"\(comment ?? "")\")".indented(by: indent)
        return code
    }
    
    func toObjcCode(visibility: Visibility) -> String {
        let chunks = prefix.split(separator: ".")
        let name = chunks.dropFirst().map { String($0).capitalizingFirstLetter() }.joined(separator: "_")
        let args = arguments.sorted(by: { $0.name < $1.name }).map { "\($0.name): \($0.type.type)" }.joined(separator: ", ")
        let args2 = arguments.sorted(by: { $0.name < $1.name }).map { "\($0.name): \($0.name)" }.joined(separator: ", ")
        return "\(visibility.rawValue) static func \(name)(\(args)) -> String { return \(prefix)(\(args2)) }".indented(by: 2)
    }
}
