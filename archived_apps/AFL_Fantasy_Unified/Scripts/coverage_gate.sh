#!/usr/bin/env bash
set -euo pipefail

# Coverage Gate Script - Following iOS standards from rules
THRESHOLD=${1:-80}
PROFDATA=$(find . -name "*.profdata" | head -n1 || true)

echo "🧪 Running coverage analysis..."

if [[ -z "$PROFDATA" ]]; then
    echo "❌ No coverage data found - run tests with coverage enabled first"
    echo "Example: xcodebuild test -enableCodeCoverage YES ..."
    exit 1
fi

# Get coverage percentage
PCT=$(xcrun llvm-cov report "$PROFDATA" 2>/dev/null | awk '/TOTAL/ {print int($4)}' || echo "0")

if [[ "$PCT" -lt "$THRESHOLD" ]]; then
    echo "❌ Coverage $PCT% is below threshold of $THRESHOLD%"
    exit 1
fi

echo "✅ Coverage OK: $PCT% (threshold: $THRESHOLD%)"
