#!/usr/bin/env bash

# AFL Fantasy Intelligence - Coverage Gate Script
# Enforces minimum code coverage threshold

set -euo pipefail

THRESHOLD=${1:-80}
PROFDATA=$(find . -name "*.profdata" | head -n1 || true)

if [[ -z "$PROFDATA" ]]; then
    echo "⚠️  No coverage data found. Run tests with coverage enabled first."
    exit 0
fi

# Get coverage percentage
PCT=$(xcrun llvm-cov report "$PROFDATA" 2>/dev/null | awk '/TOTAL/ {print int($4)}' || echo "0")

if [[ "$PCT" -lt "$THRESHOLD" ]]; then
    echo "❌ Coverage $PCT% is below threshold of $THRESHOLD%"
    exit 1
else
    echo "✅ Coverage $PCT% meets threshold of $THRESHOLD%"
fi
