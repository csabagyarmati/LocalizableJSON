//
//  LocalizedStringsPresistor.swift
//  JSONToStrings
//
//  Created by ALi on 2020. 08. 11..
//  Copyright © 2020. Csaba Gyarmati. All rights reserved.
//

import Foundation

class LocalizedStringsPresistor {
    
    class func save(_ localizedStrings: LocalizedStrings, into dirUrl: URL) {
        let sortedKeys = localizedStrings.allKeys.sorted()

        let strings = generateStrings(
            forLanguages: Array(localizedStrings.languages),
            withKeys: sortedKeys,
            from: localizedStrings.languageFiles)
        writeLanguageFiles(from: strings, into: dirUrl)
    }

    private class func generateStrings(forLanguages languages: [String],
                         withKeys keys: [String],
                         from languageFiles: [String: [String: String]]) -> [String: String] {
        var strings: [String: String] = [:]
        for language in languages {
            var stringFile = "// Generated from Localizable.json\n"
            var lastKeyElement: String?
            for key in keys {
                let keyComponents = key.split(separator: ".")
                if lastKeyElement != String(keyComponents[0]) {
                    stringFile += "\n// \(keyComponents[0])\n"
                    lastKeyElement = String(keyComponents[0])
                }
                if let value = languageFiles[language]![key] {
                    let scalars = value.unicodeScalars
                    var escapedValue = ""
                    for scalar in scalars {
                        escapedValue += scalar.escaped(asASCII: false)
                    }
                    stringFile += "\"\(key)\" = \"\(escapedValue)\";\n"
                }
            }
            strings[language] = stringFile
        }
        
        return strings
    }

    private class func writeLanguageFiles(from strings: [String: String], into dirUrl: URL) {
        for (language, stringFile) in strings {
            let languageStringsFileURL = dirUrl.appendingPathComponent("\(language).lproj", isDirectory: true).appendingPathComponent("Localizable.strings")
            do {
                try stringFile.write(to: languageStringsFileURL, atomically: true, encoding: .utf8)
            } catch {
                print("\(languageStringsFileURL.path) doesn't exist, it won't be generated.")
            }
        }
    }
}
