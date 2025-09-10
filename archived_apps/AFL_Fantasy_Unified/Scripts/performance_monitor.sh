#!/usr/bin/env bash
set -euo pipefail

# 🏈 AFL Fantasy Performance Monitor
# Checks file sizes, code quality, and HIG compliance

echo "🏈 AFL Fantasy - Performance Monitor"
echo "===================================="

# Performance budgets from your iOS standards
MAX_FILE_LINES=400
MAX_FUNCTION_LINES=40
MAX_COMPLEXITY=10

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Track issues
ISSUES=0

echo ""
echo "📏 File Size Analysis"
echo "-------------------"

# Check file sizes against SwiftLint limits
echo "Files exceeding $MAX_FILE_LINES lines:"
while IFS= read -r -d '' file; do
    lines=$(wc -l < "$file")
    if [ "$lines" -gt $MAX_FILE_LINES ]; then
        echo -e "${RED}❌ $(basename "$file"): $lines lines (limit: $MAX_FILE_LINES)${NC}"
        ((ISSUES++))
    fi
done < <(find Sources -name "*.swift" -print0)

# Show compliant files
echo ""
echo "Files under $MAX_FILE_LINES lines:"
while IFS= read -r -d '' file; do
    lines=$(wc -l < "$file")
    if [ "$lines" -le $MAX_FILE_LINES ]; then
        echo -e "${GREEN}✅ $(basename "$file"): $lines lines${NC}"
    fi
done < <(find Sources -name "*.swift" -print0)

echo ""
echo "🔍 Code Quality Check"
echo "-------------------"

# Force unwrap check (risky in production)
force_unwraps=$(grep -r "!" Sources --include="*.swift" | grep -v "// swiftlint:disable" | wc -l || true)
if [ "$force_unwraps" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $force_unwraps force unwraps (consider reducing)${NC}"
    # Show some examples
    echo "Examples:"
    grep -r "!" Sources --include="*.swift" | head -3 | while read line; do
        echo "  $line"
    done
else
    echo -e "${GREEN}✅ No force unwraps found${NC}"
fi

# Print statement check (should use logging in production)
print_statements=$(grep -r "print(" Sources --include="*.swift" | grep -v "// swiftlint:disable" | wc -l || true)
if [ "$print_statements" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $print_statements print statements (consider using Logger)${NC}"
else
    echo -e "${GREEN}✅ No print statements found${NC}"
fi

# TODO comment check
todos=$(grep -r "TODO\|FIXME\|HACK" Sources --include="*.swift" | wc -l || true)
if [ "$todos" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $todos TODO/FIXME/HACK comments${NC}"
else
    echo -e "${GREEN}✅ No TODO/FIXME/HACK comments${NC}"
fi

echo ""
echo "🎨 HIG Compliance Check"
echo "---------------------"

# Hardcoded strings (should be localizable)
hardcoded_strings=$(grep -r '"[A-Za-z]' Sources --include="*.swift" | grep -v "localizedString\|NSLocalizedString\|Text(" | wc -l || true)
if [ "$hardcoded_strings" -gt 10 ]; then
    echo -e "${YELLOW}⚠️  Found $hardcoded_strings potential hardcoded UI strings${NC}"
else
    echo -e "${GREEN}✅ Minimal hardcoded strings found${NC}"
fi

# Check for accessibility labels
accessibility_labels=$(grep -r "accessibilityLabel\|accessibilityHint" Sources --include="*.swift" | wc -l || true)
if [ "$accessibility_labels" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $accessibility_labels accessibility labels${NC}"
else
    echo -e "${YELLOW}⚠️  No accessibility labels found (add for better VoiceOver)${NC}"
fi

echo ""
echo "🏗️ Architecture Check"
echo "-------------------"

# Check for MVVM pattern compliance
viewmodels=$(find Sources -name "*ViewModel.swift" | wc -l)
views=$(find Sources -name "*View.swift" | wc -l)

if [ "$viewmodels" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $viewmodels ViewModels (MVVM pattern)${NC}"
else
    echo -e "${YELLOW}⚠️  No ViewModels found (consider MVVM pattern)${NC}"
fi

# Check for proper separation
models=$(find Sources -path "*/Models/*" -name "*.swift" | wc -l)
if [ "$models" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $models model files in Models directory${NC}"
else
    echo -e "${YELLOW}⚠️  No models in Models directory${NC}"
fi

# Check for theme usage
theme_usage=$(grep -r "Theme\." Sources --include="*.swift" | wc -l || true)
if [ "$theme_usage" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $theme_usage theme usages (consistent styling)${NC}"
else
    echo -e "${YELLOW}⚠️  No theme usage found (consider using unified theme)${NC}"
fi

echo ""
echo "📊 Summary"
echo "--------"

total_files=$(find Sources -name "*.swift" | wc -l)
total_lines=$(find Sources -name "*.swift" -exec wc -l {} + | tail -n 1 | awk '{print $1}')

echo "Total Swift files: $total_files"
echo "Total lines of code: $total_lines"
echo "Average lines per file: $((total_lines / total_files))"

if [ "$ISSUES" -eq 0 ]; then
    echo -e "${GREEN}🎉 All files comply with size limits!${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ISSUES file size violations${NC}"
    exit 1
fi
