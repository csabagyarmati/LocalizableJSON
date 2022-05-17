//
//  StringExtensions.swift
//  JSONToStrings
//
//  Created by Csaba Gyarmati on 2022. 05. 17..
//  Copyright © 2022. Csaba Gyarmati. All rights reserved.
//

import Foundation

fileprivate let badChars = CharacterSet.alphanumerics.inverted

extension String {
    
    var uppercasingFirst: String {
        return prefix(1).uppercased() + dropFirst()
    }

    var lowercasingFirst: String {
        return prefix(1).lowercased() + dropFirst()
    }

    var camelized: String {
        guard !isEmpty else { return "" }

        let parts = self.components(separatedBy: badChars)

        let first = String(describing: parts.first!).lowercasingFirst
        let rest = parts.dropFirst().map({String($0).uppercasingFirst})

        return ([first] + rest).joined(separator: "")
    }
}
