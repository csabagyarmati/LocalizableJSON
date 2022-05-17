//
//  main.swift
//  JSONToStrings
//
//  Created by Csaba Gyarmati on 2019. 09. 26..
//  Copyright © 2019. Csaba Gyarmati. All rights reserved.
//

import Foundation
import ArgumentParser

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}

struct JsonToStrings: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "JSONToStrings")
    
    @Option(name: .shortAndLong, help: "Path of Localizable.json and target path of Localizable.strings files.")
    var path: String
    
    @Flag(name: .shortAndLong, help: "Generate keys swift file.")
    var generateKeys: Bool = false

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
            throw RuntimeError("Path not exists: \(dirURL.path)")
        }
        if !isDir.boolValue {
            throw RuntimeError("Provided path is not a folder: \(dirURL.path)")
        }

        let fileURL = dirURL.appendingPathComponent("Localizable.json")
        if !fileManager.fileExists(atPath: fileURL.path) {
            throw RuntimeError("Localizable.json not found at path: \(fileURL.path)")
        }

        guard let jsonData = try? Data(contentsOf: fileURL) else {
            throw RuntimeError("Couldn't read Localizable.json file.")
        }

        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw RuntimeError("Serialization error at processing Localizable.json")
        }
        
        return GeneratorArguments(json: json, dirUrl: dirURL, generateKeys: generateKeys)
    }
}

JsonToStrings.main()
