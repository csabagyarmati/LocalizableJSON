//
//  KeyGenerator.swift
//  JSONToStrings
//
//  Created by Csaba Gyarmati on 2022. 05. 17..
//  Copyright © 2022. Csaba Gyarmati. All rights reserved.
//

import Foundation

class KeyGenerator {
    
    let stringKeys: [LocalizationKey]
    let dirURL: URL
    
    private var localizationKeys: [String: Any] = [:]
    
    init(stringKeys: Set<LocalizationKey>, dirURL: URL) {
        self.stringKeys = stringKeys.sorted()
        self.dirURL = dirURL
    }
    
    func generateKeys() {
        for key in stringKeys {
            let keyComponents = key.split(separator: ".")
            localizationKeys = addComponent(keyComponents, to: localizationKeys, key: key)
        }
        saveKeys(into: dirURL)
    }
    
    private func addComponent(_ keyComponents: [String.SubSequence], to dict: [String: Any], key: String) -> [String: Any] {
        var components = keyComponents
        var keyDict = dict
        let rootComponent = String(components.removeFirst()).camelized
        if keyDict.keys.contains(rootComponent) {
            if let dict = keyDict[rootComponent] as? [String: Any] {
                keyDict[rootComponent] = addComponent(components, to: dict, key: key)
            } else if let keyString = keyDict[rootComponent] as? String {
                if components.count > 0 {
                    assertionFailure("Key and dictionary conflict at \(keyString) in \(key)")
                } else {
                    if keyString == key {
                        assertionFailure("Duplicated key \(key)")
                    }
                }
            }
        } else {
            if components.count > 0 {
                keyDict[rootComponent] = addComponent(components, to: [:], key: key)
            } else {
                keyDict[rootComponent] = key
            }
        }
        
        return keyDict
    }
    
    private func saveKeys(into dirURL: URL) {
        var stringFile = "// Generated from Localizable.json\n\nimport Foundation\n\nstruct L {\n"
        stringFile += createLine(from: localizationKeys, indent: 4)
        stringFile += "}\n"

        let fileURL = dirURL.appendingPathComponent("Localizable.swift")
        do {
            try stringFile.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error creating keys file.")
        }
    }
    
    private func createLine(from keyDict: [String: Any], indent: Int) -> String {
        var line = ""
        
        for key in keyDict.keys.sorted() {
            var allIndent = ""
            for _ in 0..<indent { allIndent += " " }

            if let dict = keyDict[key] as? [String: Any] {
                line += "\(allIndent)struct \(key) {\n"
                line += createLine(from: dict, indent: indent + 4)
                line += "\(allIndent)}\n"
            } else if let keyString = keyDict[key] as? String {
                line += "\(allIndent)static let \(key) = \"\(keyString)\"\n"
            }
        }
        return line
    }
    
}
