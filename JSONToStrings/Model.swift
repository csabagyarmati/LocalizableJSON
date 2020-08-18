//
//  Model.swift
//  JSONToStrings
//
//  Created by ALi on 2020. 08. 11..
//  Copyright © 2020. Csaba Gyarmati. All rights reserved.
//

import Foundation

typealias LocaleCode = String
typealias LocalizationKey = String
typealias LocalizedString = String
typealias PluralSpecifier = String
typealias LocalizedPluralArgs = [String: String]

struct LocalizedStrings {
    var allKeys: Set<LocalizationKey> = []
    var languageFiles: [LocaleCode: [LocalizationKey: LocalizedString]] = [:]
    var languages: Set<LocaleCode> {
        .init(languageFiles.keys)
    }
    
    mutating func addLocalizedString(_ key: LocalizationKey, for localeCode: LocaleCode, localizedString: LocalizedString) {
        if languageFiles[localeCode] == nil {
            languageFiles[localeCode] = [:]
        }
        languageFiles[localeCode]?[key] = localizedString
        allKeys.insert(key)
    }
}

struct LocalizedPluralStrings {
    var languageFiles: [LocaleCode: [LocalizationKey: LocalizedPluralFormat]] = [:]
    
    mutating func addLocalizedPluralString(_ key: LocalizationKey, for localeCode: LocaleCode, pluralFormat: LocalizedPluralFormat) {
        if !languageFiles.keys.contains(localeCode) {
            languageFiles[localeCode] = [:]
        }
        languageFiles[localeCode]?[key] = pluralFormat
    }
}

struct LocalizedPluralFormat: Encodable {
    var NSStringLocalizedFormatKey: String 
    var arg: LocalizedPluralArgs
}

extension LocalizedPluralArgs {
    static var mandatoryPart: [String: String] = [
        "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
        "NSStringFormatValueTypeKey": "d"
    ]
}
