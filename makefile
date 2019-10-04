TEMPORARY_FOLDER?=/tmp/LocalizableJSON.dst
BUILD_FOLDER?=build
PREFIX?=/usr/local
BUILD_TOOL?=xcodebuild

XCODEFLAGS_GENSTRINGSJSON=-project 'GenStringsJSON.xcodeproj' \
	-target 'GenStringsJSON' \
	-configuration Release
XCODEFLAGS_JSONTOSTRINGS=-project 'JSONToStrings.xcodeproj' \
	-target 'JSONToStrings' \
	-configuration Release

BINARIES_FOLDER=/usr/local/bin
LICENSE_PATH="$(shell pwd)/LICENSE"

all: build

clean:
	rm -rf "$(BUILD_FOLDER)"
	rm -rf "$(TEMPORARY_FOLDER)"
	rm -f "./portable_LocalizableJSON.zip"

build:
	xcodebuild $(XCODEFLAGS_GENSTRINGSJSON)
	xcodebuild $(XCODEFLAGS_JSONTOSTRINGS)

install: build
	install -d "$(BINARIES_FOLDER)"
	install "$(BUILD_FOLDER)/Release/GenStringsJSON" "$(BINARIES_FOLDER)"
	install "$(BUILD_FOLDER)/Release/JSONToStrings" "$(BINARIES_FOLDER)"

uninstall:
	rm -f "$(BINARIES_FOLDER)/GenStringsJSON"
	rm -f "$(BINARIES_FOLDER)/JSONToStrings"

installables: build
	install -d "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	install "$(BUILD_FOLDER)/Release/GenStringsJSON" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	install "$(BUILD_FOLDER)/Release/JSONToStrings" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"

portable_zip: installables
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/GenStringsJSON" "$(TEMPORARY_FOLDER)"
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/JSONToStrings" "$(TEMPORARY_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "GenStringsJSON" "JSONToStrings" "LICENSE") > "./portable_LocalizableJSON.zip"

release: portable_zip

push_version:
ifneq ($(strip $(shell git status --untracked-files=no --porcelain 2>/dev/null)),)
	$(error git state is not clean)
endif
	$(eval NEW_VERSION_AND_NAME := $(filter-out $@,$(MAKECMDGOALS)))
	$(eval NEW_VERSION := $(shell echo $(NEW_VERSION_AND_NAME) | sed 's/:.*//' ))
	@sed -i '' 's/## Master/## $(NEW_VERSION_AND_NAME)/g' CHANGELOG.md
	@sed 's/__VERSION__/$(NEW_VERSION)/g' script/Version.swift.template > Source/SwiftLintFramework/Models/Version.swift
	@/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(NEW_VERSION)" "$(SWIFTLINTFRAMEWORK_PLIST)"
	@/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(NEW_VERSION)" "$(SWIFTLINT_PLIST)"
	git commit -a -m "release $(NEW_VERSION)"
	git tag -a $(NEW_VERSION) -m "$(NEW_VERSION_AND_NAME)"
	git push origin master
	git push origin $(NEW_VERSION)

%:
	@: