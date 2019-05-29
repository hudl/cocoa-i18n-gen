//
//  Argument.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

struct Argument {
    
    private static let regex = try! NSRegularExpression(pattern: "\\{(.*?)\\}", options: [.caseInsensitive])
    
    let name: String
    let type: ArgumentType

    static func parseArgs(strValue: String, arguments: [String: String]?) -> [Argument] {
        // Optimization, if it doesn't contain a { char, no need to perform a regex on it.
        guard strValue.contains("{") else { return [] }
        
        let nsrange = NSRange(strValue.startIndex..<strValue.endIndex, in: strValue)
        let matches = regex.matches(in: strValue, options: [], range: nsrange)
        return matches.compactMap { match -> Argument? in
            let nsrange = match.range(at: 1)
            if let range = Range(nsrange, in: strValue) {
                let substr = String(strValue[range])
                return Argument(name: substr, type: ArgumentType(rawValue: arguments?[substr] ?? "string")!)
            }
            return nil
        }
    }
}

extension Array where Element == Argument {
    
    var asInput: String {
        return sorted(by: { $0.name < $1.name })
            .map { "\($0.name): \($0.type.type)" }
            .joined(separator: ", ")
    }
    
    var asFormatting: String {
        return sorted(by: { $0.name < $1.name })
            .map { $0.name }
            .joined(separator: ", ")
    }
    
    var asInvocation: String {
        return sorted(by: { $0.name < $1.name })
        .map { "\($0.name): \($0.name)" }
        .joined(separator: ", ")
    }
    
}

enum ArgumentType: String {
    case number, string, double
    
    var type: String {
        switch self {
        case .number: return "Int"
        case .string: return "String"
        case .double: return "Double"
        }
    }
}
