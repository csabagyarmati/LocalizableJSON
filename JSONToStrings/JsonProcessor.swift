//
//  JsonProcessor.swift
//  JSONToStrings
//
//  Created by ALi on 2020. 08. 11..
//  Copyright © 2020. Csaba Gyarmati. All rights reserved.
//

import Foundation

class JsonProcessor {
    
    struct Result {
        var localizedStrings: LocalizedStrings = .init()
        var localizedPlurals: LocalizedPluralStrings = .init()
        
        mutating func addLocalizedString(_ key: LocalizationKey, for localeCode: LocaleCode, localizedString: LocalizedString) {
            localizedStrings.addLocalizedString(key, for: localeCode, localizedString: localizedString)
        }
    }
    
    private var result: Result!

    func process(json: [String: Any]) -> Result {
        result = Result()
        processJSON(json, builtKey: nil)
        
        return result
    }
    
    private func processJSON(_ json: [String: Any], builtKey: String?) {
        for (key, value) in json {
            switch key {
            case "flags":
                continue
            case "plural":
                if let builtKey = builtKey {
                    guard let localizedPlurals = value as? [LocaleCode: [PluralSpecifier: String]] else { continue }
                    for (localeCode, pluralSpecs) in localizedPlurals {
                        guard let format = pluralSpecs["format"] else { fatalError("Plural specification without format: \(builtKey): \(pluralSpecs)")}
                        guard pluralSpecs.keys.contains("other") else { fatalError("Plural specification must have \"other\" specifier! \(builtKey): \(pluralSpecs)")}
                        
                        result.localizedPlurals.addLocalizedPluralString(
                            builtKey,
                            for: localeCode,
                            pluralFormat: LocalizedPluralFormat(
                                NSStringLocalizedFormatKey: format.updateArgSpecifier(),
                                arg: LocalizedPluralArgs.mandatoryPart
                                    .merging(pluralSpecs.filter { $0.key != "format" }, uniquingKeysWith: { arg1, _ in arg1 })
                            ))
                    }
                }
            default:
                if let stringValue = value as? String, let localizationKey = builtKey {
                    result.addLocalizedString(localizationKey, for: key, localizedString: stringValue)
                } else if let dictValue = value as? [String: Any] {
                    if let newKey = builtKey {
                        processJSON(dictValue, builtKey: "\(newKey).\(key)")
                    } else {
                        processJSON(dictValue, builtKey: "\(key)")
                    }
                }
            }
        }
    }
}

private extension String {
    func updateArgSpecifier() -> String {
        guard contains("%@") else {
            fatalError("Format doesn't contain argument specifier! \(self)")
        }
        
        return replacingOccurrences(of: "%@", with: "%#@arg@")
    }
}
