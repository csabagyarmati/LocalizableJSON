# LocalizableJSON
[![Version](https://img.shields.io/cocoapods/v/LocalizableJSON.svg?style=flat)](https://cocoapods.org/pods/LocalizableJSON)
[![License](https://img.shields.io/cocoapods/l/LocalizableJSON.svg?style=flat)](https://cocoapods.org/pods/LocalizableJSON)
[![Platform](https://img.shields.io/cocoapods/p/LocalizableJSON.svg?style=flat)](https://cocoapods.org/pods/LocalizableJSON)

Generate a file called Localized.json from the source code containing all the keys of localized strings.
Generate Localized.strings and Localized.stringsdict from Localized.json.

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

Localized.json generated from the source code, based on localization related functions. Check the following source code to unerstand it.
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

### Command line switches

#### --path

Root directory of your project.

#### --remove-unused

Remove unused keys from Localizable.json during generation.

#### --language

An array of generating locale codes separated with spaces. This switch is optional.

## JSONToStrings

### Command line switches

#### --path

Root directory of your project.
