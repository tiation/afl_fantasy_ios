#!/usr/bin/env bash
set -euo pipefail

THRESHOLD=${1:-80}
echo "📊 Code Coverage Gate - Minimum: ${THRESHOLD}%"

# Find the most recent .profdata file
PROFDATA=$(find . -name "*.profdata" | head -n1 || true)

if [[ -z "$PROFDATA" ]]; then
    echo "❌ No coverage data found. Run tests with coverage enabled first."
    echo "💡 xcodebuild -enableCodeCoverage YES test"
    exit 1
fi

echo "🔍 Found coverage data: $PROFDATA"

# Extract coverage percentage using llvm-cov
PCT=$(xcrun llvm-cov report "$PROFDATA" 2>/dev/null | awk '/TOTAL/ {print int($4)}' || echo "0")

if [[ "$PCT" -lt "$THRESHOLD" ]]; then
    echo "❌ Coverage $PCT% is below minimum $THRESHOLD%"
    echo "🎯 Improve test coverage to meet quality standards"
    exit 1
fi

echo "✅ Coverage OK: $PCT% (meets ${THRESHOLD}% minimum)"
echo "🎉 Code quality gate passed!"
