//
//  Plural.swift
//  CocoaLocoCore
//
//  Created by Brian Clymer on 5/29/19.
//

import Foundation

struct Plural: CodeGeneratable {
    
    private static var variableCount = 0
    
    enum Transformation {
        case standard, key, pseudo
    }
    
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
        
        let code = """
        \(visibility.rawValue) static func \(normalizedName)(count: Int) -> String { return \(body) }
        private static let _\(normalizedName) = Foundation.NSLocalizedString("\(keyWithoutRootNamespace)", bundle: __bundle, comment: "\(comment ?? "")")
        """
        return code
    }
    
    func toObjcCode(visibility: Visibility) -> String {
        let chunks = fullNamespace.split(separator: ".")
        let name = chunks.dropFirst().map { String($0).capitalizingFirstLetter() }.joined(separator: "_")
        let body = "return \(fullNamespace)(count: count)"
        return "\(visibility.rawValue) static func \(name)(count: Int)) -> String { \(body) }"
    }
    
    func toXml(transformation: Transformation) -> String {
        Plural.variableCount += 1
        let variableName = "variable_\(Plural.variableCount)"
        return """
        <key>\(normalizedName)</key>
        <dict>
        <key>NSStringFormatValueTypeKey</key>
        <string>%#@\(variableName)@</string>
        <key>\(variableName)</key>
        <dict>
        <key>NSStringFormatSpecTypeKey</key>
        <string>NSStringPluralRuleType</string>
        <key>NSStringFormatValueTypeKey</key>
        <string>NEED TO IDENTIFY TYPE</string>
        \(pluralVariationsXml(transformation: transformation))
        </dict>
        </dict>
        """
    }
    
    func pluralVariationsXml(transformation: Transformation) -> String {
        return [(other, "other"), (one, "one"), (zero, "zero"), (two, "two"), (few, "few"), (many, "many")]
            .compactMap { (value, name) -> String? in
                guard let value = value else { return nil }
                return """
                <key>\(name)</key>
                <string>\(value)</key>
                """
            }
            .joined(separator: "\n")
    }
    
    // TODO Should enforce rules somehow. Throw a good error basically.
    // Required they have a %i or something in there.
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
                      zero: dict["zero"] as? String,
                      two: dict["two"] as? String,
                      few: dict["few"] as? String,
                      many: dict["many"] as? String)
    }
    
}
