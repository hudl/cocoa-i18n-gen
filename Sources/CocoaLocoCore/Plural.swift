//
//  Plural.swift
//  CocoaLocoCore
//
//  Created by Brian Clymer on 5/29/19.
//

import Foundation

struct Plural: CodeGeneratable {
    
    private static let regex = try! NSRegularExpression(pattern: #"%[^%\s]*\w"#, options: [.caseInsensitive])
    private static var variableCount = 0
    
    enum Transformation {
        case standard, key, pseudo
        
        func transform(value: String, namespace: String) -> String {
            switch self {
            case .standard: return value
            case .key: return namespace.split(separator: ".").dropFirst().joined(separator: ".") // Drop LocalizableStrings.
            // TODO still need to actually run the pseudo generator.
            case .pseudo: return value
            }
        }
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
    
    // Calculated
    private let variableType: String
    private let variableId: Int
    
    init(normalizedName: String,
         fullNamespace: String,
         comment: String?,
         other: String,
         one: String,
         zero: String?,
         two: String?,
         few: String?,
         many: String?) {
        self.normalizedName = normalizedName
        self.fullNamespace = fullNamespace
        self.comment = comment
        self.other = other
        self.one = one
        self.zero = zero
        self.two = two
        self.few = few
        self.many = many
        
        let nsrange = NSRange(other.startIndex..<other.endIndex, in: other)
        let matches = Plural.regex.matches(in: other, options: [], range: nsrange)
        guard let foundRange = matches.first?.range(at: 0), let range = Range(foundRange, in: other) else {
            fatalError("No variable type found in plural. Add a %i or %lu or something")
        }
        
        variableType = String(other[range].dropFirst())
        variableId = Plural.variableCount
        Plural.variableCount += 1
    }
    
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
        let variableName = "variable_\(variableId)"
        return """
        <key>\(normalizedName)</key>
        <dict>
        <key>NSStringLocalizedFormatKey</key>
        <string>%#@\(variableName)@</string>
        <key>\(variableName)</key>
        <dict>
        <key>NSStringFormatSpecTypeKey</key>
        <string>NSStringPluralRuleType</string>
        <key>NSStringFormatValueTypeKey</key>
        <string>\(variableType)</string>
        \(pluralVariationsXml(transformation: transformation))
        </dict>
        </dict>
        """
    }
    
    func pluralVariationsXml(transformation: Transformation) -> String {
        return [(one, "one"), (other, "other"), (zero, "zero"), (two, "two"), (few, "few"), (many, "many")]
            .compactMap { (value, name) -> String? in
                guard let value = value else { return nil }
                return """
                <key>\(name)</key>
                <string>\(transformation.transform(value: value, namespace: fullNamespace))</string>
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
