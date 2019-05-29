//
//  CodeGeneratable.swift
//  CocoaLocoCore
//
//  Created by Brian Clymer on 5/29/19.
//

import Foundation

protocol CodeGeneratable {
    var normalizedName: String { get }
}

extension Array where Element: CodeGeneratable {
    func toCode(indent: Int, _ transform: ((Element) -> String)) -> String {
        var code = self
            .sorted(by: { $0.normalizedName < $1.normalizedName })
            .map { transform($0) }
            .map { $0.indented(by: indent + 2) }
            .joined(separator: "\n")
        if !self.isEmpty {
            code += "\n"
        }
        return code
    }
}
