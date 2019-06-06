//
//  String+Extensions.swift
//  Cocoa i18n
//
//  Created by Brian Clymer on 5/27/19.
//  Copyright © 2019 Hudl. All rights reserved.
//

import Foundation

extension String {
    func indentEachLine(by: Int) -> String {
        // add spaces to the first line, and then add spaces after every new line.
        let spaces = String(repeating: " ", count: by)
        return spaces + self.replacingOccurrences(of: "\n", with: "\n" + spaces)
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    func lowercaseFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}
