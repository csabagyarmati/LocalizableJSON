# LocalizableJSON
[![Version](https://img.shields.io/cocoapods/v/LocalizableJSON.svg?style=flat)](https://cocoapods.org/pods/LocalizableJSON)
[![License](https://img.shields.io/cocoapods/l/LocalizableJSON.svg?style=flat)](https://cocoapods.org/pods/LocalizableJSON)
[![Platform](https://img.shields.io/cocoapods/p/LocalizableJSON.svg?style=flat)](https://cocoapods.org/pods/LocalizableJSON)

Generate a file called Localizable.json from the source code containing all the keys of localized strings.
Generate Localizable.strings and Localizable.stringsdict from Localizable.json.

## Installation

```ruby
pod 'LocalizedJSON'
```

## Usage

Add the following Run Script for generating Localized.json for English and French localization.
```
${PODS_ROOT}/LocalizableJSON/GenStringsJSON en fr --path ${SRCROOT}/Your-project-dir
```

Add the following Run Script for generating Localized.strings and Localized.stringsdict by Localized.json.
```
${PODS_ROOT}/LocalizableJSON/JSONToStrings --path ${SRCROOT}/Your-project-dir
```

## Generation strategy

Localizable.json generated from the source code, based on localization related functions. Check the following source code to understand it.
```swift
// When using standard localization method

// GenStringsJSON will generate an entry for "travelCard.blockingAlert.title"
NSLocalizedString("travelCard.blockingAlert.title", comment: "")
```
```swift
// When using Localize-Swift for localization

// GenStringsJSON will generate an entry for "travelCard.blockingAlert.title"
title = "travelCard.blockingAlert.title".localized()

// GenStringsJSON will generate an entry for "travelCard.acceptTerms.text"
let text = "travelCard.acceptTerms.text".localizedFormat(customerName)

// GenStringsJSON will generate an entry for "boxStorage.hint.title"
let text = "boxStorage.hint.title".localizedPlural(numberOfBoxes)
```

## GenStringsJSON

```bash
USAGE: GenStringsJSON [--path <path>] [--remove-unused] [<language codes> ...]

ARGUMENTS:
  <language codes>        Specify language local codes which will be presented
                          in Localizable.json. 
        The default value is "en" if there is nothing specified.

OPTIONS:
  -p, --path <path>       Root path of project localization keys collecting
                          from. 
        Default is the current folder.
  -r, --remove-unused     Remove all unused localization keys from
                          Localized.json after generation. 
        Default value is false.
  -h, --help              Show help information.
```
## JSONToStrings

```bash
USAGE: JSONToStrings --path <path>

OPTIONS:
  -p, --path <path>       Path of Localizable.json and target path of
                          Localizable.strings files. 
  -h, --help              Show help information.
 ```