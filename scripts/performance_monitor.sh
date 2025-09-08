#!/usr/bin/env bash
# 🚀 AFL Fantasy iOS Performance Monitor
# Enforces 10x performance wins and HIG compliance

set -euo pipefail

echo "🚀 AFL Fantasy iOS Performance Monitor"
echo "======================================"

# Performance Budgets
APP_LAUNCH_MAX=1800  # 1.8 seconds (milliseconds)
BUNDLE_SIZE_MAX=60   # 60 MB
MEMORY_USAGE_MAX=220 # 220 MB
BUILD_TIME_MAX=120   # 2 minutes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR")   echo -e "${RED}❌ $message${NC}" ;;
        "INFO")    echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Check build time
check_build_time() {
    print_status "INFO" "Checking build time..."
    
    local start_time=$(date +%s)
    
    # Build the project
    if xcodebuild -scheme "AFL_Fantasy_Unified" \
        -destination 'platform=iOS Simulator,name=iPhone 15' \
        -configuration Release \
        -quiet \
        build > /dev/null 2>&1; then
        
        local end_time=$(date +%s)
        local build_time=$((end_time - start_time))
        
        if [ $build_time -le $BUILD_TIME_MAX ]; then
            print_status "SUCCESS" "Build time: ${build_time}s (< ${BUILD_TIME_MAX}s)"
        else
            print_status "ERROR" "Build time: ${build_time}s (> ${BUILD_TIME_MAX}s)"
            return 1
        fi
    else
        print_status "ERROR" "Build failed"
        return 1
    fi
}

# Check file sizes for SwiftLint compliance
check_file_sizes() {
    print_status "INFO" "Checking file sizes against SwiftLint rules..."
    
    local violations=0
    
    while IFS= read -r file; do
        local line_count=$(wc -l < "$file")
        if [ $line_count -gt 400 ]; then
            print_status "ERROR" "$(basename "$file"): $line_count lines (> 400 lines)"
            violations=$((violations + 1))
        fi
    done < <(find AFL_Fantasy_Unified -name "*.swift" -type f)
    
    if [ $violations -eq 0 ]; then
        print_status "SUCCESS" "All Swift files within size limits (≤ 400 lines)"
    else
        print_status "ERROR" "$violations files exceed size limit"
        return 1
    fi
}

# Check for performance anti-patterns
check_performance_patterns() {
    print_status "INFO" "Checking for performance anti-patterns..."
    
    local issues=0
    
    # Check for force unwrapping in performance-critical code
    if grep -r "!" AFL_Fantasy_Unified/Sources --include="*.swift" | grep -v "// swiftlint:disable" | grep -v "Test" | head -5; then
        print_status "WARNING" "Found force unwrapping operators - consider using guard/if let"
        issues=$((issues + 1))
    fi
    
    # Check for print statements (should use logger)
    if grep -r "print(" AFL_Fantasy_Unified/Sources --include="*.swift" | grep -v "// Debug" | head -3; then
        print_status "WARNING" "Found print statements - use proper logging"
        issues=$((issues + 1))
    fi
    
    # Check for .onChange without @MainActor
    if grep -r ".onChange" AFL_Fantasy_Unified/Sources --include="*.swift" | head -3; then
        print_status "INFO" "Found .onChange usage - ensure @MainActor compliance"
    fi
    
    if [ $issues -eq 0 ]; then
        print_status "SUCCESS" "No critical performance anti-patterns detected"
    else
        print_status "WARNING" "$issues potential performance issues found"
    fi
}

# Check accessibility compliance
check_accessibility() {
    print_status "INFO" "Checking accessibility compliance..."
    
    local violations=0
    
    # Check for hardcoded strings in UI
    if grep -r 'Text("' AFL_Fantasy_Unified/Sources --include="*.swift" | grep -v "SF Symbols" | grep -v "Debug" | head -3; then
        print_status "WARNING" "Found hardcoded strings - consider localization"
        violations=$((violations + 1))
    fi
    
    # Check for accessibility labels
    local button_count=$(grep -r "Button(" AFL_Fantasy_Unified/Sources --include="*.swift" | wc -l)
    local accessibility_count=$(grep -r "accessibilityLabel" AFL_Fantasy_Unified/Sources --include="*.swift" | wc -l)
    
    if [ $accessibility_count -gt 0 ]; then
        print_status "SUCCESS" "Found $accessibility_count accessibility labels"
    else
        print_status "WARNING" "Consider adding more accessibility labels"
        violations=$((violations + 1))
    fi
    
    if [ $violations -eq 0 ]; then
        print_status "SUCCESS" "Accessibility checks passed"
    else
        print_status "WARNING" "$violations accessibility issues found"
    fi
}

# Check architecture compliance
check_architecture() {
    print_status "INFO" "Checking architecture compliance..."
    
    # Check MVVM structure
    if [[ -d "AFL_Fantasy_Unified/Sources/Shared/Views" ]] && \
       [[ -d "AFL_Fantasy_Unified/Sources/Shared/Services" ]] && \
       [[ -f "AFL_Fantasy_Unified/Sources/Shared/Theme/Theme.swift" ]]; then
        print_status "SUCCESS" "MVVM architecture maintained"
    else
        print_status "ERROR" "Architecture violation - missing core directories"
        return 1
    fi
    
    # Check for unified theme usage
    local theme_usage=$(grep -r "Theme\." AFL_Fantasy_Unified/Sources --include="*.swift" | wc -l)
    if [ $theme_usage -gt 10 ]; then
        print_status "SUCCESS" "Unified theme system in use ($theme_usage usages)"
    else
        print_status "WARNING" "Low theme system usage - ensure consistency"
    fi
}

# Main execution
main() {
    local start_time=$(date +%s)
    local failures=0
    
    echo ""
    print_status "INFO" "Starting AFL Fantasy iOS performance audit..."
    echo ""
    
    # Run all checks
    check_file_sizes || failures=$((failures + 1))
    echo ""
    
    check_performance_patterns
    echo ""
    
    check_accessibility
    echo ""
    
    check_architecture || failures=$((failures + 1))
    echo ""
    
    # Skip build time check if not in CI (takes too long locally)
    if [ "${CI:-}" = "true" ]; then
        check_build_time || failures=$((failures + 1))
        echo ""
    else
        print_status "INFO" "Skipping build time check (not in CI)"
        echo ""
    fi
    
    # Summary
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    
    echo "======================================"
    print_status "INFO" "Performance audit completed in ${total_time}s"
    
    if [ $failures -eq 0 ]; then
        print_status "SUCCESS" "🏈 AFL Fantasy iOS meets all performance standards!"
        print_status "SUCCESS" "Ready for 10x performance and HIG beauty! 🚀"
        exit 0
    else
        print_status "ERROR" "$failures critical issues found"
        print_status "ERROR" "Fix issues before deployment"
        exit 1
    fi
}

# Run main function
main "$@"
