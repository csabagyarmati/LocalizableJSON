//
//  main.swift
//  JSONToStrings
//
//  Created by Csaba Gyarmati on 2019. 09. 26..
//  Copyright © 2019. Csaba Gyarmati. All rights reserved.
//

import Foundation

//let startTime = Date().timeIntervalSince1970
var languageFiles: [String: [String: String]] = [:]
var languages: Set<String> = []
var allKeys: Set<String> = []

func errorMessage(_ message: String) {
    print("Error: \(message)")
}

func usage() {
    print("JSONToStrings directory")
}

let arguments = CommandLine.arguments
if arguments.count != 2 {
    errorMessage("argument error")
    usage()
    exit(0)
}

let dirString = arguments[1]
let dirURL = URL(fileURLWithPath: dirString)
let fileManager = FileManager.default
var isDir: ObjCBool = false
if !fileManager.fileExists(atPath: dirURL.path, isDirectory: &isDir) {
    errorMessage("file not exists")
    usage()
    exit(0)
}
if !isDir.boolValue {
    errorMessage("exists, but not directory")
    usage()
    exit(0)
}

let fileURL = dirURL.appendingPathComponent("Localizable.json")
if !fileManager.fileExists(atPath: fileURL.path) {
    errorMessage("Localizable.json not found")
    usage()
    exit(0)
}

guard let jsonData = try? Data(contentsOf: fileURL) else {
    errorMessage("could not read Localizable.json")
    usage()
    exit(0)
}

guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
    errorMessage("serialization error")
    usage()
    exit(0)
}

func processJSON(_ json: [String: Any], builtKey: String?) {
    for (key, value) in json {
        if let stringValue = value as? String {
            if languageFiles[key] == nil {
                languageFiles[key] = [:]
                languages.insert(key)
            }
            if let newKey = builtKey {
                languageFiles[key]![newKey] = stringValue
                allKeys.insert(newKey)
            }
        } else if let dictValue = value as? [String: Any] {
            if let newKey = builtKey {
                processJSON(dictValue, builtKey: "\(newKey).\(key)")
            } else {
                processJSON(dictValue, builtKey: "\(key)")
            }
        }
    }
}

func generateStrings(forLanguages languages: [String],
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

func writeLanguageFiles(from strings: [String: String]) {
    for (language, stringFile) in strings {
        let languageStringsFileURL = dirURL.appendingPathComponent("\(language).lproj", isDirectory: true).appendingPathComponent("Localizable.strings")
        do {
            try stringFile.write(to: languageStringsFileURL, atomically: true, encoding: .utf8)
        } catch {
            errorMessage("error writing language file \(language)")
        }
    }
}

processJSON(json, builtKey: nil)
let sortedKeys = allKeys.sorted()

let strings = generateStrings(forLanguages: Array(languages), withKeys: sortedKeys, from: languageFiles)
writeLanguageFiles(from: strings)
//let diff = Date().timeIntervalSince1970 - startTime
//print("Finished in \(diff) seconds")
