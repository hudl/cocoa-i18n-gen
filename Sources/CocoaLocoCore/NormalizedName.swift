//
//  NormalizedName.swift
//  CocoaLocoCore
//
//  Created by Brian Clymer on 5/29/19.
//

import Foundation

let reservedKeywords: Set<String> = Set([
    "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init", "inout", "internal",
    "let", "open", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var",
    "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat",
    "return", "switch", "where", "while", "as", "Any", "catch", "false", "is", "nil", "rethrows", "super", "self", "Self",
    "throw", "throws", "true", "try", "associativity", "convenience", "dynamic", "didSet", "final", "get", "infix", "indirect",
    "lazy", "left", "mutating", "none", "nonmutating", "optional", "override", "postfix", "precedence", "prefix", "Protocol",
    "required", "right", "set", "Type", "unowned", "weak", "willSet"
])

func normalizeName(rawName: String) -> String {
    if reservedKeywords.contains(rawName) {
        return "`\(rawName)`"
    }
    return rawName
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
}

/// Takes 2 strings and creates a dot separated string out of them. There will be no dot
/// if the first string is `nil`
///
/// - Parameters:
///   - part1: The parent namespace string. If this is `nil` no dot will be added and the 2nd part will be returned as is.
///   - part2: The child namespace string.
/// - Returns: The full namespace combining the two provided parts.
func joinedNamespace(part1: String?, part2: String) -> String {
    if let part1 = part1, !part1.isEmpty {
        return "\(part1).\(part2)"
    } else {
        return part2
    }
}
