//
//  String+Extensions.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

extension String {
    func indented(by: Int) -> String {
        return String(repeating: " ", count: by) + self
    }
    func indentEachLine(by: Int) -> String {
        return self
            .components(separatedBy: .newlines)
            .map { $0.isEmpty ? $0 : $0.indented(by: by) }
            .joined(separator: "\n")
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    func lowercaseFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
    func removeEmptyLines() -> String {
        return self
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }
}
