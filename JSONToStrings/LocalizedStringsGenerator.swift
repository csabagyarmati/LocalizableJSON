//
//  LocalizedStringsGenerator.swift
//  JSONToStrings
//
//  Created by ALi on 2020. 08. 11..
//  Copyright © 2020. Csaba Gyarmati. All rights reserved.
//

import Foundation

struct GeneratorArguments {
    var json: [String: Any]
    var dirUrl: URL
    var generateKeys: Bool
}

class LocalizedStringsGenerator {
    
    let args: GeneratorArguments
    
    init(args: GeneratorArguments) {
        self.args = args
    }

    func generate() {
        let jsonProcessor = JsonProcessor()
        let result = jsonProcessor.process(json: args.json)
        
        LocalizedStringsPresistor.save(result.localizedStrings, into: args.dirUrl)
        LocalizedPluralStringsPersistor.save(result.localizedPlurals, into: args.dirUrl)
        
        if args.generateKeys {
            let keyGenerator = KeyGenerator(stringKeys: result.localizedStrings.allKeys, dirURL: args.dirUrl)
            keyGenerator.generateKeys()
        }
    }
}
