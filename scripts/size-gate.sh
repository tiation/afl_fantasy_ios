#!/usr/bin/env bash
set -euo pipefail

# Bundle size gates from your standards
JS_MAX=90000   # 90 KB gz
CSS_MAX=45000  # 45 KB gz
FAIL=0

echo "🔍 Checking bundle sizes..."

# Check if dist directory exists
if [ ! -d "dist" ]; then
  echo "⚠️ No dist directory found. Run build first."
  exit 0
fi

# Check JavaScript bundles
for f in $(find dist -name "*.js" 2>/dev/null); do
  SIZE=$(gzip -c "$f" | wc -c)
  if [ $SIZE -gt $JS_MAX ]; then
    echo "❌ $f is $(($SIZE / 1024))KB gzipped (limit: 90KB)"
    FAIL=1
  else
    echo "✅ $f is $(($SIZE / 1024))KB gzipped"
  fi
done

# Check CSS bundles
for f in $(find dist -name "*.css" 2>/dev/null); do
  SIZE=$(gzip -c "$f" | wc -c)
  if [ $SIZE -gt $CSS_MAX ]; then
    echo "❌ $f is $(($SIZE / 1024))KB gzipped (limit: 45KB)"
    FAIL=1
  else
    echo "✅ $f is $(($SIZE / 1024))KB gzipped"
  fi
done

if [ $FAIL -eq 0 ]; then
  echo "✅ All bundles within size limits!"
else
  echo "❌ Some bundles exceed size limits"
fi

exit $FAIL
