//
//  Plural.swift
//  CocoaLocoCore
//
//  Created by Brian Clymer on 5/29/19.
//

import Foundation

struct Plural: CodeGeneratable {

    private static let regex = try! NSRegularExpression(pattern: #"%[^%\s]*\w"#, options: [.caseInsensitive])

    enum InitializationError: Error {
        case missingInterpolations
    }

    enum Transformation {
        case standard, key, pseudo

        func transform(value: String, namespace: String) -> String {
            switch self {
            case .standard: return value
            case .key: return namespace
            case .pseudo: return PseudoLocalizer.coolify(str: value)
            }
        }
    }

    let key: String
    let normalizedName: String
    let swiftFullFunc: String
    let swiftKey: String
    let prefix: String
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

    init?(key: String,
          namespace: String?,
          prefix: String,
          comment: String?,
          other: String,
          one: String,
          zero: String?,
          two: String?,
          few: String?,
          many: String?) {
        self.key = key
        self.normalizedName = normalizeName(rawName: key)
        self.prefix = prefix
        self.comment = comment
        self.other = other
        self.one = one
        self.zero = zero
        self.two = two
        self.few = few
        self.many = many
        self.swiftKey = joinedNamespace(part1: namespace, part2: key)
        self.swiftFullFunc = joinedNamespace(part1: namespace, part2: normalizedName)

        let nsrange = NSRange(other.startIndex..<other.endIndex, in: other)
        let matches = Plural.regex.matches(in: other, options: [], range: nsrange)
        guard let foundRange = matches.first?.range(at: 0), let range = Range(foundRange, in: other) else {
            return nil
        }

        variableType = String(other[range].dropFirst())
    }

    func toSwiftCode(visibility: Visibility) -> String {
        let privateVal = "_\(normalizedName)"
        let body = "String.localizedStringWithFormat(\(privateVal), count)"

        let tableName = prefix.isEmpty ? "" : #", tableName: "\#(prefix)Localizable""#
        let code = """
        \(visibility.rawValue) static func \(normalizedName)(count: Int) -> String { return \(body) }
        private static let _\(normalizedName) = Foundation.NSLocalizedString("\(swiftKey)"\(tableName), bundle: __bundle, comment: "\(comment ?? "")")
        """
        return code
    }

    func toObjcCode(visibility: Visibility) -> String {
        let name = swiftFullFunc
            .split(separator: ".")
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: "_")
        let body = "return \(swiftFullFunc)(count: count)"
        return "\(visibility.rawValue) static func \(name)(count: Int)) -> String { \(body) }"
    }

    func toXml(transformation: Transformation, index: Int) -> String {
        let variableName = "variable_\(index)"
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

    private func pluralVariationsXml(transformation: Transformation) -> String {
        return [(one, "one"), (other, "other"), (zero, "zero"), (two, "two"), (few, "few"), (many, "many")]
            .compactMap { (value, name) -> String? in
                guard let value = value else { return nil }
                return """
                <key>\(name)</key>
                <string>\(transformation.transform(value: value, namespace: swiftFullFunc))</string>
                """
            }
            .joined(separator: "\n")
    }

    static func asPlural(_ value: Any, key: String, namespace: String?, prefix: String) -> Plural? {
        guard
            let dict = value as? [String: Any],
            let other = dict["other"] as? String,
            let one = dict["one"] as? String
        else { return nil }

        return Plural(key: key,
                      namespace: namespace,
                      prefix: prefix,
                      comment: dict["comment"] as? String,
                      other: other,
                      one: one,
                      zero: dict["zero"] as? String,
                      two: dict["two"] as? String,
                      few: dict["few"] as? String,
                      many: dict["many"] as? String)
    }

}

// Big thanks to https://github.com/maxnachlinger/node-pseudo-l10n
private class PseudoLocalizer {

    private static let charMap: [Character: String] = [
        "a": "ààà", "b": "ƀ", "c": "ç", "d": "ð", "e": "ééé", "f": "ƒ", "g": "ĝ", "h": "ĥ", "i": "îîî", "l": "ļ", "k": "ķ", "j": "ĵ", "m": "ɱ",
        "n": "ñ", "o": "ôôô", "p": "þ", "q": "ǫ", "r": "ŕ", "s": "š", "t": "ţ", "u": "ûûû", "v": "ṽ", "w": "ŵ", "x": "ẋ", "y": "ý", "z": "ž",
        "A": "ÀÀÀ", "B": "Ɓ", "C": "Ç", "D": "Ð", "E": "ÉÉÉ", "F": "Ƒ", "G": "Ĝ", "H": "Ĥ", "I": "ÎÎÎ", "L": "Ļ", "K": "Ķ", "J": "Ĵ", "M": "Ṁ",
        "N": "Ñ", "O": "ÔÔÔ", "P": "Þ", "Q": "Ǫ", "R": "Ŕ", "S": "Š", "T": "Ţ", "U": "ÛÛÛ", "V": "Ṽ", "W": "Ŵ", "X": "Ẋ", "Y": "Ý", "Z": "Ž"
    ]

    public static let htmlChars: [Character] = [" ", ",", ":", ";", "?", "!", "[", "/", "-", "(", "<", "{"]

    public static let ignoreMap: [Character: ((Character) -> Bool)] = [
        "<": { char -> Bool in
            return char == ">"
        },
        "%": { char -> Bool in
            return htmlChars.contains(char)
        }
    ]

    static func coolify(str: String) -> String {
        guard !str.isEmpty else { return str }
        var output = ""
        var ignoreFn: ((Character) -> Bool)?

        str.enumerated().forEach { _, char in
            var charToAppend = String(char)
            // if we can stop ignoring
            if let localIgnoreFn = ignoreFn, localIgnoreFn(char) {
                ignoreFn = nil
            }
            if ignoreFn == nil {
                // if we need to start ignoring
                ignoreFn = ignoreMap[char]

                if let mappedChar = charMap[char], ignoreFn == nil {
                    charToAppend = mappedChar
                }
            }
            output.append(charToAppend)
        }

        return output
    }

}
