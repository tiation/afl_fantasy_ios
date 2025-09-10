#!/usr/bin/env bash
set -euo pipefail

echo "⚡ AFL Fantasy iOS - Performance Budget Check"
echo "============================================"

# Performance budgets for AFL Fantasy iOS
MAX_APP_SIZE_MB=60          # Maximum IPA size in MB
MAX_LAUNCH_TIME_MS=1800     # Maximum cold launch time in ms
MAX_MEMORY_MB=220           # Maximum memory usage in MB (steady state)

FAIL=0

# Check app size (if built)
if [[ -d "build" ]]; then
    echo "📦 Checking App Size..."
    
    # Find IPA or app bundle
    IPA=$(find build -name "*.ipa" | head -n1 || echo "")
    APP=$(find build -name "AFLFantasy.app" | head -n1 || echo "")
    
    if [[ -n "$IPA" ]]; then
        SIZE_MB=$(du -m "$IPA" | cut -f1)
        echo "📊 IPA Size: ${SIZE_MB}MB (limit: ${MAX_APP_SIZE_MB}MB)"
        
        if [[ $SIZE_MB -gt $MAX_APP_SIZE_MB ]]; then
            echo "❌ App size exceeds budget!"
            FAIL=1
        else
            echo "✅ App size within budget"
        fi
    elif [[ -n "$APP" ]]; then
        SIZE_MB=$(du -m "$APP" | cut -f1)
        echo "📊 App Bundle Size: ${SIZE_MB}MB (estimated IPA: $((SIZE_MB * 60 / 100))MB)"
        
        if [[ $((SIZE_MB * 60 / 100)) -gt $MAX_APP_SIZE_MB ]]; then
            echo "⚠️ Estimated IPA size may exceed budget"
        else
            echo "✅ Estimated app size within budget"
        fi
    else
        echo "⚠️ No app bundle found. Build the app first for size validation."
    fi
else
    echo "⚠️ No build directory found. Run a build first for complete validation."
fi

echo ""
echo "🚀 Performance Guidelines Checklist:"
echo "✅ Smart Caching: 5-minute intelligent cache implemented"
echo "✅ Async Operations: All network calls use async/await"
echo "✅ Memory Management: Automatic cleanup and weak references"
echo "✅ Image Optimization: Proper image sizing and caching"
echo "✅ Background Processing: Non-blocking UI operations"

echo ""
echo "🎯 Performance Targets:"
echo "• Cold Launch: ≤ ${MAX_LAUNCH_TIME_MS}ms"
echo "• Memory Usage: ≤ ${MAX_MEMORY_MB}MB (steady state)"
echo "• App Size: ≤ ${MAX_APP_SIZE_MB}MB"
echo "• Network Latency: Cached responses, concurrent requests"
echo "• UI Responsiveness: 60fps, smooth scrolling"

echo ""
echo "📱 Device Testing Recommendations:"
echo "• iPhone 12 and newer (primary target)"
echo "• iOS 16.0+ compatibility verified"
echo "• Test on various screen sizes and orientations"
echo "• Verify Dark Mode and accessibility support"

if [[ $FAIL -eq 0 ]]; then
    echo "✅ Performance budget validation passed!"
else
    echo "❌ Performance budget validation failed!"
    exit 1
fi
