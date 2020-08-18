//
//  main.swift
//  GenStringsJSON
//
//  Created by Csaba Gyarmati on 2019. 09. 27..
//  Copyright © 2019. Csaba Gyarmati. All rights reserved.
//

import Foundation
import ArgumentParser

struct CommandLineSwitches {
    var removeUnusedEntries: Bool
}

class GenStrings {

    let commandLineSwitches: CommandLineSwitches
    let fileManager = FileManager.default
    let acceptedFileExtensions = ["swift"]
    let excludedFolderNames = ["Carthage"]
    let excludedFileNames = ["genstrings.swift"]
    var regularExpresions = [String:NSRegularExpression]()

    let localizedRegex = "(?<=\")([^\"]*)(?=\".(localized|localizedFormat|localizedPlural))|(?<=(Localized|NSLocalizedString)\\(\")([^\"]*?)(?=\")"

    enum GenstringsError: Error {
        case Error
    }

    init(commandLineSwitches: CommandLineSwitches) {
        self.commandLineSwitches = commandLineSwitches
    }
    
    // Performs the genstrings functionality
    func perform(languages: [String], path: String? = nil) {
        let directoryPath = path ?? fileManager.currentDirectoryPath
        let rootPath = URL(fileURLWithPath:directoryPath)
        let loadedJson = loadJsonIfExists(at: rootPath)
        var localizableStrings = Set<String>()
        var jsonKeys = [String]()
        if let keys = loadedJson?.keys {
            jsonKeys.append(contentsOf: keys)
            for key in keys {
                localizableStrings.insert(key)
            }
        }
        let allFiles = fetchFilesInFolder(rootPath: rootPath)
        // We use a set to avoid duplicates
        var retrievedKeys = Set<String>()
        for filePath in allFiles {
            let stringsInFile = localizableStringsInFile(filePath: filePath)
            localizableStrings = localizableStrings.union(stringsInFile)
            retrievedKeys = retrievedKeys.union(stringsInFile)
        }
        // We sort the strings
        let sortedStrings = localizableStrings.sorted(by: { $0 < $1 })
        var processedJson: [String: Any] = [:]
        for string in sortedStrings {
            if jsonKeys.contains(string) {
                if retrievedKeys.contains(string) || !commandLineSwitches.removeUnusedEntries {
                    processedJson[string] = loadedJson![string]
                }
            } else {
                var value: [String: String] = [:]
                for language in languages {
                    value[language] = string
                }
                processedJson[string] = value
            }
        }
        // Write out Localizable.json
        writeJsonString(JSONStringify(value: processedJson as AnyObject, prettyPrinted: true), to: rootPath)
    }
    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        let options: JSONSerialization.WritingOptions = prettyPrinted ? [.prettyPrinted, .sortedKeys] : []
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = String(data: data, encoding: .utf8) {
                    return string
                }
            } catch {
                return ""
            }
        }
        return ""
    }
    
    func loadJsonIfExists(at path: URL) -> [String: Any]? {
        let fileURL = path.appendingPathComponent("Localizable.json")
        if !fileManager.fileExists(atPath: fileURL.path) {
            return nil
        }

        guard let jsonData = try? Data(contentsOf: fileURL) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { return nil }

        return json
    }
    
    @discardableResult func writeJsonString(_ jsonString: String, to path: URL) -> Bool {
        let fileURL = path.appendingPathComponent("Localizable.json")
        do {
            try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    // Applies regex to a file at filePath.
    func localizableStringsInFile(filePath: URL) -> Set<String> {
        do {
            let fileContentsData = try Data(contentsOf: filePath)
            guard let fileContentsString = NSString(data: fileContentsData, encoding: String.Encoding.utf8.rawValue) else {
                return Set<String>()
            }
            let localizedStringsArray = try regexMatches(pattern: localizedRegex, string: fileContentsString as String).map({fileContentsString.substring(with: $0.range)})
            return Set(localizedStringsArray)
        } catch {}
        return Set<String>()
    }

    //MARK: Regex

    func regexWithPattern(pattern: String) throws -> NSRegularExpression {
        var safeRegex = regularExpresions
        if let regex = safeRegex[pattern] {
            return regex
        }
        else {
            do {
                let currentPattern: NSRegularExpression
                currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpression.Options.caseInsensitive)
                safeRegex.updateValue(currentPattern, forKey: pattern)
                regularExpresions = safeRegex
                return currentPattern
            }
            catch {
                throw GenstringsError.Error
            }
        }
    }

    func regexMatches(pattern: String, string: String) throws -> [NSTextCheckingResult] {
        do {
            let internalString = string
            let currentPattern =  try regexWithPattern(pattern: pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = internalString as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = currentPattern.matches(in: internalString, options: [], range: stringRange)
            return matches
        }
        catch {
            throw GenstringsError.Error
        }
    }

    //MARK: File manager

    func fetchFilesInFolder(rootPath: URL) -> [URL] {
        var files = [URL]()
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: rootPath as URL, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            for urlPath in directoryContents {
                let stringPath = urlPath.path
                let lastPathComponent = urlPath.lastPathComponent
                let pathExtension = urlPath.pathExtension
                var isDir : ObjCBool = false
                if fileManager.fileExists(atPath: stringPath, isDirectory:&isDir) {
                    if isDir.boolValue {
                        if !excludedFolderNames.contains(lastPathComponent) {
                            let dirFiles = fetchFilesInFolder(rootPath: urlPath)
                            files.append(contentsOf: dirFiles)
                        }
                    } else {
                        if acceptedFileExtensions.contains(pathExtension) && !excludedFileNames.contains(lastPathComponent)  {
                            files.append(urlPath)
                        }
                    }
                }
            }
        } catch {}
        return files
    }

}

func pathExistsAndIsDirectory(_ path: String) -> Bool {
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
        if isDir.boolValue {
            return true
        }
    }
    
    return false
}

struct GenStringJSON: ParsableCommand {
    @Flag(help: "Remove all unused localization keys from Localized.json after generation.")
    var removeUnused = false
    
    @Option(help: "Root path of project localization keys collecting from.")
    var path: String?
    
    @Argument(help: "Specify language local codes which will be presented in Localizable.json. The default value is en if there is nothing specified.")
    var languages: [String] = []
    
    func run() throws {
        let genStrings = GenStrings(commandLineSwitches: CommandLineSwitches(removeUnusedEntries: removeUnused))
        genStrings.perform(languages: languages, path: path)
    }
}

GenStringJSON.main()
