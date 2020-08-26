//
//  LocalizedPluralStringsPersistor.swift
//  JSONToStrings
//
//  Created by ALi on 2020. 08. 11..
//  Copyright © 2020. Csaba Gyarmati. All rights reserved.
//

import Foundation

class LocalizedPluralStringsPersistor {
    
    class func save(_ localizedPluralStrings: LocalizedPluralStrings, into dirUrl: URL) {
        localizedPluralStrings.languageFiles.forEach { (localeCode, localizedPluralStrings) in
            writePlist(localizedPluralStrings.escaping(), for: localeCode, into: dirUrl)
        }
    }
    
    private class func writePlist(_ plist: [LocalizationKey: LocalizedPluralFormat], for localeCode: LocaleCode, into dirUrl: URL) {
        let path = dirUrl
            .appendingPathComponent("\(localeCode).lproj", isDirectory: true)
                .appendingPathComponent("Localizable.stringsdict")
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(plist)
            try data.write(to: path)
        } catch {
            print("\(path.path) doesn't exist, it won't be generated.")
        }
    }
}

extension Dictionary where Key == LocalizationKey, Value == LocalizedPluralFormat {
    func escaping() -> Self {
        mapValues { LocalizedPluralFormat(
            NSStringLocalizedFormatKey: $0.NSStringLocalizedFormatKey.escaping(),
            arg: $0.arg.escaping())
        }
    }
}

extension LocalizedPluralArgs {
    func escaping() -> LocalizedPluralArgs {
        mapValues{ $0.escaping() }
    }
}

extension String {
    
    func escaping() -> String {
        let scalars = self.unicodeScalars
        var escapedValue = ""
        for scalar in scalars {
            escapedValue += scalar.fixEscapedCharacter()
        }
        return escapedValue
    }
    
}

extension Unicode.Scalar {
    
    func fixEscapedCharacter() -> String {
        let source: [Unicode.Scalar] = ["\n", "\r", "\t", "\\", "\"", "'"]
        let target: [Unicode.Scalar] = ["\u{a}", "\u{d}", "\u{9}", "\u{5c}", "\u{22}", "\u{27}"]
        for (index, char) in source.enumerated() {
            if self == char { return String(target[index]) }
        }
        return self.escaped(asASCII: false)
    }
    
}
