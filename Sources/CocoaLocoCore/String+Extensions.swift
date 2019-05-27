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
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    func lowercaseFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}
