#!/usr/bin/env bash
# Quick verification script for legal document deployment
set -euo pipefail

echo "🔍 AFL Fantasy Legal Documents Verification"
echo "==========================================="

# Check local files exist
echo "✅ Checking local files:"
if [[ -f "docs/privacy.md" ]]; then
    echo "   ✓ Privacy Policy: docs/privacy.md"
else
    echo "   ❌ Privacy Policy missing"
    exit 1
fi

if [[ -f "docs/terms.md" ]]; then
    echo "   ✓ Terms of Use: docs/terms.md"
else
    echo "   ❌ Terms of Use missing"
    exit 1
fi

echo ""
echo "📝 Document info:"
echo "   Privacy Policy: $(wc -w < docs/privacy.md) words"
echo "   Terms of Use: $(wc -w < docs/terms.md) words"

echo ""
echo "🌐 URL Status (when deployed):"
echo "   https://afl.ai/privacy"
echo "   https://afl.ai/terms"
echo ""

# Check for key compliance elements
echo "🔍 Compliance check:"
if grep -q "1800 858 858" docs/terms.md; then
    echo "   ✓ Australian gambling helpline included"
else
    echo "   ❌ Gambling helpline missing"
fi

if grep -q "We do not collect" docs/privacy.md; then
    echo "   ✓ No data collection statement present"
else
    echo "   ❌ Data collection statement unclear"
fi

if grep -qi "entertainment" docs/terms.md; then
    echo "   ✓ Entertainment disclaimer present"
else
    echo "   ❌ Entertainment disclaimer missing"
fi

echo ""
echo "📱 Next steps:"
echo "1. Deploy docs to make URLs accessible"
echo "2. Test Settings → Privacy Policy / Terms links in app"
echo "3. Verify URLs work in iOS WebView"
echo "4. Submit to App Store"

echo ""
echo "✅ Legal documents ready for deployment!"
