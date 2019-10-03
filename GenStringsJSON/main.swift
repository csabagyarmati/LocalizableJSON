//
//  main.swift
//  GenStringsJSON
//
//  Created by Csaba Gyarmati on 2019. 09. 27..
//  Copyright © 2019. Csaba Gyarmati. All rights reserved.
//

import Foundation

class GenStrings {

    var str = "Hello, playground"
    let fileManager = FileManager.default
    let acceptedFileExtensions = ["swift"]
    let excludedFolderNames = ["Carthage"]
    let excludedFileNames = ["genstrings.swift"]
    var regularExpresions = [String:NSRegularExpression]()

    let localizedRegex = "(?<=\")([^\"]*)(?=\".(localized|localizedFormat))|(?<=(Localized|NSLocalizedString)\\(\")([^\"]*?)(?=\")"

    enum GenstringsError: Error {
        case Error
    }

    // Performs the genstrings functionality
    func perform(languages: [String], path: String? = nil) {
        let directoryPath = path ?? fileManager.currentDirectoryPath
        let rootPath = URL(fileURLWithPath:directoryPath)
        let allFiles = fetchFilesInFolder(rootPath: rootPath)
        // We use a set to avoid duplicates
        var localizableStrings = Set<String>()
        for filePath in allFiles {
            let stringsInFile = localizableStringsInFile(filePath: filePath)
            localizableStrings = localizableStrings.union(stringsInFile)
        }
        // We sort the strings
        let sortedStrings = localizableStrings.sorted(by: { $0 < $1 })
        var processedStrings = String()
        processedStrings.append("{\n")
        for (sIndex, string) in sortedStrings.enumerated() {
            processedStrings.append("  \"\(string)\": {\n")
            for (index, language) in languages.enumerated() {
                processedStrings.append("    \"\(language)\": \"\(string)\"")
                if index < languages.count - 1 {
                    processedStrings.append(",")
                }
                processedStrings.append("\n")
            }
            processedStrings.append("  }")
            if sIndex < sortedStrings.count - 1 {
                processedStrings.append(",")
            }
            processedStrings.append("\n")
        }
        processedStrings.append("}\n")
        print(processedStrings)
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

//let startTime = Date().timeIntervalSince1970
let genStrings = GenStrings()
var languages: Set<String> = ["en"]
let path = CommandLine.arguments.last!
if pathExistsAndIsDirectory(path) {
    if CommandLine.arguments.count > 2 {
        for i in 1..<CommandLine.arguments.count - 1 {
            languages.insert(CommandLine.arguments[i])
        }
    }
    genStrings.perform(languages: Array(languages), path: path)
} else {
    if CommandLine.arguments.count > 1 {
        for i in 1..<CommandLine.arguments.count {
            languages.insert(CommandLine.arguments[i])
        }
    }
    genStrings.perform(languages: Array(languages))
}
//print("Finished in \(Date().timeIntervalSince1970 - startTime) seconds")
