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
        return String(repeating: " ", count: by) +
            self.replacingOccurrences(of: "\n", with: "\n" + String(repeating: " ", count: by))
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    func lowercaseFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}
