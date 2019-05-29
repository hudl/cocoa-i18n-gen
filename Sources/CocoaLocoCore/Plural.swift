//
//  Plural.swift
//  CocoaLocoCore
//
//  Created by Brian Clymer on 5/29/19.
//

import Foundation

struct Plural: CodeGeneratable {
    
    let normalizedName: String
    let fullNamespace: String
    let comment: String?
    
    // Required
    let other: String
    let one: String
    
    // Optional
    let zero: String?
    let two: String?
    let few: String?
    let many: String?
    
    func toSwiftCode(visibility: Visibility, swiftEnum: LocalizationNamespace) -> String {
        let privateVal = "_\(normalizedName)"
        let keyWithoutRootNamespace = fullNamespace.split(separator: ".").dropFirst().joined(separator: ".")
        let body = "String.localizedStringWithFormat(\(privateVal), count)"
        
        let code = #"""
        \#(visibility.rawValue) static func \#(normalizedName)(count: Int) -> String { return \#(body) }
        private static let _\#(normalizedName) = Foundation.NSLocalizedString("\#(keyWithoutRootNamespace)", comment: "\#(comment ?? "")")
        """#
        return code
    }
    
    func toObjcCode(visibility: Visibility) -> String {
        let chunks = fullNamespace.split(separator: ".")
        let name = chunks.dropFirst().map { String($0).capitalizingFirstLetter() }.joined(separator: "_")
        let body = "return \(fullNamespace)(count: count)"
        return "\(visibility.rawValue) static func \(name)(count: Int)) -> String { \(body) }".indented(by: 2)
    }
    
    static func asPlural(_ value: Any, normalizedName: String, fullNamespace: String) -> Plural? {
        guard
            let dict = value as? [String: Any],
            let other = dict["other"] as? String,
            let one = dict["one"] as? String
        else { return nil }
        
        return Plural(normalizedName: normalizedName,
                      fullNamespace: fullNamespace,
                      comment: dict["comment"] as? String,
                      other: other,
                      one: one,
                      zero: dict["other"] as? String,
                      two: dict["two"] as? String,
                      few: dict["few"] as? String,
                      many: dict["many"] as? String)
    }
    
}
