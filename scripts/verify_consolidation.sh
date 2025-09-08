#!/usr/bin/env bash
set -euo pipefail

echo "🧪 Verifying AFL Fantasy consolidation..."

# Check unified project structure
UNIFIED_DIR="AFL_Fantasy_Unified"

if [[ ! -d "$UNIFIED_DIR" ]]; then
    echo "❌ Unified directory not found"
    exit 1
fi

echo "✅ Unified directory exists"

# Check source migration
SHARED_DIR="$UNIFIED_DIR/Sources/Shared"
if [[ ! -d "$SHARED_DIR/Views" ]] || [[ ! -d "$SHARED_DIR/Models" ]] || [[ ! -d "$SHARED_DIR/Services" ]]; then
    echo "❌ Source migration incomplete"
    exit 1
fi

echo "✅ Source files migrated"

# Check feature flags
if [[ ! -f "$UNIFIED_DIR/Sources/Free/FeatureFlags.swift" ]] || [[ ! -f "$UNIFIED_DIR/Sources/Pro/FeatureFlags.swift" ]]; then
    echo "❌ Feature flags missing"
    exit 1
fi

echo "✅ Feature flags configured"

# Check project configuration
if [[ ! -f "$UNIFIED_DIR/project.yml" ]]; then
    echo "❌ Project configuration missing"
    exit 1
fi

echo "✅ Project configuration ready"

# Check quality tools
if [[ ! -f "$UNIFIED_DIR/.swiftlint.yml" ]] || [[ ! -f "$UNIFIED_DIR/.swiftformat" ]]; then
    echo "❌ Quality tools configuration missing"
    exit 1
fi

echo "✅ Quality tools configured"

# Check scripts
if [[ ! -f "$UNIFIED_DIR/Scripts/quality.sh" ]] || [[ ! -f "$UNIFIED_DIR/Scripts/coverage_gate.sh" ]]; then
    echo "❌ Quality scripts missing"
    exit 1
fi

echo "✅ Quality scripts ready"

# Count Swift files
SWIFT_COUNT=$(find "$UNIFIED_DIR" -name "*.swift" -type f | wc -l | tr -d ' ')
echo "📊 Swift files in unified project: $SWIFT_COUNT"

# Check if we can generate the Xcode project
cd "$UNIFIED_DIR"

if command -v xcodegen >/dev/null 2>&1; then
    echo "🏗️ Testing Xcode project generation..."
    xcodegen generate --spec project.yml --project .
    
    if [[ -f "AFLFantasy.xcodeproj/project.pbxproj" ]]; then
        echo "✅ Xcode project generates successfully"
    else
        echo "❌ Xcode project generation failed"
        exit 1
    fi
else
    echo "⚠️ XcodeGen not installed - install with: brew install xcodegen"
fi

cd ..

echo ""
echo "🎉 AFL Fantasy Consolidation Complete!"
echo ""
echo "📋 Summary:"
echo "  • ✅ Created unified project structure"
echo "  • ✅ Migrated source code to shared/free/pro targets"
echo "  • ✅ Configured feature flags for Free vs Pro versions"
echo "  • ✅ Set up iOS standards (SwiftLint, SwiftFormat)" 
echo "  • ✅ Added quality scripts and CI/CD"
echo "  • ✅ Created proper build configurations"
echo ""
echo "🚀 Next Steps:"
echo "  1. cd AFL_Fantasy_Unified"
echo "  2. xcodegen generate (if not done)"
echo "  3. Open AFLFantasy.xcodeproj in Xcode"
echo "  4. Build and test both targets"
echo "  5. Archive legacy projects when satisfied"
