#!/bin/bash
set -euo pipefail

# Check SwiftFormat is installed
if ! command -v swiftformat >/dev/null; then
  echo "Installing SwiftFormat..."
  brew install swiftformat
fi

# Check SwiftLint is installed  
if ! command -v swiftlint >/dev/null; then
  echo "Installing SwiftLint..."
  brew install swiftlint
fi

# Format code
echo "Formatting code..."
swiftformat .

# Run linting
echo "Running SwiftLint..."
swiftlint

# Clean build folder
echo "Cleaning build folder..."
rm -rf build

# Create build directories
mkdir -p build/{Debug-iphonesimulator,Debug-iphoneos}/AFLFantasy.app

# Copy Info.plist
cp AFLFantasy/Info.plist build/Debug-iphonesimulator/AFLFantasy.app/
cp AFLFantasy/Info.plist build/Debug-iphoneos/AFLFantasy.app/

# Build for simulator
echo "Building for simulator..."
xcodebuild \
  -project AFLFantasy.xcodeproj \
  -scheme AFLFantasy \
  -sdk iphonesimulator \
  -configuration Debug \
  -derivedDataPath build \
  SYMROOT=build \
  OBJROOT=build \
  BUILD_DIR=build \
  BUILD_ROOT=build

echo "Done! App built at: build/Debug-iphonesimulator/AFLFantasy.app"
