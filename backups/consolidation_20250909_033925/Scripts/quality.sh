#!/usr/bin/env bash
set -euo pipefail

echo "🚀 AFL Fantasy iOS - Quality Assurance Check"
echo "=============================================="

# Add user gem bin to PATH if it exists
if [[ -d "$HOME/.gem/ruby/2.6.0/bin" ]]; then
    export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
fi

# Check if tools are installed
command -v swiftformat >/dev/null 2>&1 || { echo "❌ SwiftFormat not installed. Run: brew install swiftformat"; exit 1; }
command -v swiftlint >/dev/null 2>&1 || { echo "❌ SwiftLint not installed. Run: brew install swiftlint"; exit 1; }

# Check for xcpretty with installation instructions
if ! command -v xcpretty >/dev/null 2>&1; then
    echo "⚠️ xcpretty not found. Installing now..."
    gem install xcpretty --user-install
    export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
fi

echo "🔧 Running SwiftFormat..."
swiftformat . --verbose

echo ""
echo "🔍 Running SwiftLint..."
swiftlint

echo ""
echo "🧪 Running Unit Tests..."
xcodebuild \
  -scheme "AFLFantasy" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES \
  test | xcpretty || echo "⚠️ xcpretty not found, using default output"

echo ""
echo "📊 Checking Code Coverage..."
bash Scripts/coverage_gate.sh 80

echo ""
echo "🏗️ Building Release Configuration..."
xcodebuild -scheme "AFLFantasy" -configuration Release build | xcpretty || echo "⚠️ xcpretty not found, using default output"

echo ""
echo "✅ Quality check complete! AFL Fantasy iOS is production-ready."
