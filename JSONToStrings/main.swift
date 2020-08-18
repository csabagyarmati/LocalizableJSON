//
//  main.swift
//  JSONToStrings
//
//  Created by Csaba Gyarmati on 2019. 09. 26..
//  Copyright © 2019. Csaba Gyarmati. All rights reserved.
//

import Foundation
import ArgumentParser

enum JsonToStringsError: Error {
    case fileNotExists(fileName: String)
    case notADirectory(fileSpec: String)
    case localizableJsonNotFound(fileSpec: String)
    case localizableJsonCannotBeRead(fileSpec: String)
    case serializationError(fileSpec: String)
}

struct JsonToStrings: ParsableCommand {
    @Option(help: "Root path of project Localized.strings generating for.")
    var path: String

    func run() throws {
        let args = try validateArgs()
        let generator = LocalizedStringsGenerator(args: args)
        generator.generate()
    }
    
    private func validateArgs() throws -> GeneratorArguments {
        let dirURL = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: dirURL.path, isDirectory: &isDir) {
            throw JsonToStringsError.fileNotExists(fileName: dirURL.path)
        }
        if !isDir.boolValue {
            throw JsonToStringsError.notADirectory(fileSpec: dirURL.path)
        }

        let fileURL = dirURL.appendingPathComponent("Localizable.json")
        if !fileManager.fileExists(atPath: fileURL.path) {
            throw JsonToStringsError.localizableJsonNotFound(fileSpec: fileURL.path)
        }

        guard let jsonData = try? Data(contentsOf: fileURL) else {
            throw JsonToStringsError.localizableJsonCannotBeRead(fileSpec: fileURL.path)
        }

        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw JsonToStringsError.serializationError(fileSpec: fileURL.path)
        }
        
        return GeneratorArguments(json: json, dirUrl: dirURL)
    }
}

JsonToStrings.main()
