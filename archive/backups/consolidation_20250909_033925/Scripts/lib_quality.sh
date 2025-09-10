#!/usr/bin/env bash
# AFL Fantasy iOS - Quality Gates Library
# Reusable functions for build system and CI
# Source this file: source Scripts/lib_quality.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_section() {
    echo ""
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

# Check if required tools are installed
check_prerequisites() {
    log_section "Checking Prerequisites"
    
    local missing_tools=()
    
    if ! command -v swiftformat >/dev/null 2>&1; then
        missing_tools+=("swiftformat")
    fi
    
    if ! command -v swiftlint >/dev/null 2>&1; then
        missing_tools+=("swiftlint")
    fi
    
    if ! command -v xcodebuild >/dev/null 2>&1; then
        missing_tools+=("xcodebuild")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install missing tools:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                swiftformat|swiftlint)
                    echo "  brew install $tool"
                    ;;
                xcodebuild)
                    echo "  Install Xcode from App Store"
                    ;;
            esac
        done
        return 1
    fi
    
    log_success "All prerequisites installed"
    log_info "SwiftFormat: $(swiftformat --version)"
    log_info "SwiftLint: $(swiftlint version)"
    log_info "Xcode: $(xcodebuild -version | head -1)"
}

# Run SwiftFormat and check for changes
run_swiftformat() {
    log_section "Running SwiftFormat"
    
    # Get current git status to check for changes
    local before_changes
    before_changes=$(git status --porcelain | wc -l)
    
    # Run SwiftFormat
    if swiftformat . --verbose; then
        local after_changes
        after_changes=$(git status --porcelain | wc -l)
        
        if [[ $after_changes -gt $before_changes ]]; then
            log_error "SwiftFormat made changes to your code"
            log_info "Review changes and commit them before building"
            git diff --name-only
            return 1
        else
            log_success "Code formatting is correct"
        fi
    else
        log_error "SwiftFormat failed"
        return 1
    fi
}

# Run SwiftLint and check for violations
run_swiftlint() {
    log_section "Running SwiftLint"
    
    if swiftlint; then
        log_success "No SwiftLint violations found"
    else
        log_error "SwiftLint violations found"
        return 1
    fi
}

# Run tests with coverage
run_tests_with_coverage() {
    local scheme="${1:-AFLFantasy}"
    local destination="${2:-platform=iOS Simulator,name=iPhone 15,OS=18.6}"
    
    log_section "Running Tests with Coverage"
    
    # Install xcpretty if not available
    if ! command -v xcpretty >/dev/null 2>&1; then
        log_warning "xcpretty not found, installing..."
        gem install xcpretty --user-install || true
        # Add gem bin to PATH
        if [[ -d "$HOME/.gem/ruby/2.6.0/bin" ]]; then
            export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
        fi
    fi
    
    log_info "Running tests on: $destination"
    
    # Run tests with coverage
    if command -v xcpretty >/dev/null 2>&1; then
        xcodebuild \
            -scheme "$scheme" \
            -sdk iphonesimulator \
            -destination "$destination" \
            -enableCodeCoverage YES \
            test | xcpretty
    else
        log_warning "xcpretty not available, using default output"
        xcodebuild \
            -scheme "$scheme" \
            -sdk iphonesimulator \
            -destination "$destination" \
            -enableCodeCoverage YES \
            test
    fi
    
    log_success "Tests completed successfully"
}

# Enforce coverage threshold
enforce_coverage() {
    local threshold="${1:-80}"
    
    log_section "Checking Code Coverage"
    
    # Find the most recent .profdata file
    local profdata
    profdata=$(find . -name "*.profdata" | head -n1 || echo "")
    
    if [[ -z "$profdata" ]]; then
        log_error "No coverage data found"
        log_info "Run tests with coverage enabled first"
        return 1
    fi
    
    log_info "Found coverage data: $profdata"
    
    # Extract coverage percentage using llvm-cov
    local coverage_pct
    coverage_pct=$(xcrun llvm-cov report "$profdata" 2>/dev/null | awk '/TOTAL/ {print int($4)}' || echo "0")
    
    if [[ "$coverage_pct" -lt "$threshold" ]]; then
        log_error "Coverage ${coverage_pct}% is below minimum ${threshold}%"
        log_info "Improve test coverage to meet quality standards"
        
        # Show detailed coverage report
        log_info "Detailed coverage report:"
        xcrun llvm-cov report "$profdata" 2>/dev/null | head -20 || true
        
        return 1
    fi
    
    log_success "Coverage OK: ${coverage_pct}% (meets ${threshold}% minimum)"
    return 0
}

# Run all quality gates
run_all_quality_gates() {
    local coverage_threshold="${1:-80}"
    local scheme="${2:-AFLFantasy}"
    local destination="${3:-platform=iOS Simulator,name=iPhone 15}"
    
    log_section "AFL Fantasy iOS - Quality Gates"
    
    # Run all quality checks
    check_prerequisites || return 1
    run_swiftformat || return 1
    run_swiftlint || return 1
    run_tests_with_coverage "$scheme" "$destination" || return 1
    enforce_coverage "$coverage_threshold" || return 1
    
    log_success "🎉 All quality gates passed!"
}

# Performance budget check
check_performance_budget() {
    log_section "Performance Budget Check"
    
    # Run the existing performance budget script
    if [[ -f "Scripts/performance_budget.sh" ]]; then
        bash Scripts/performance_budget.sh
    else
        log_warning "Performance budget script not found"
    fi
}

# Clean build artifacts
clean_build_artifacts() {
    log_section "Cleaning Build Artifacts"
    
    # Clean Xcode derived data
    log_info "Cleaning DerivedData..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/AFLFantasy-*
    
    # Clean local build directory
    if [[ -d "build" ]]; then
        log_info "Cleaning local build directory..."
        rm -rf build
    fi
    
    log_success "Build artifacts cleaned"
}

# Validate Xcode project health
validate_project_health() {
    log_section "Validating Project Health"
    
    # Check for missing files
    log_info "Checking for missing file references..."
    
    # This is a simple check - in a real scenario you might want more sophisticated validation
    if xcodebuild -list -project AFLFantasy.xcodeproj >/dev/null 2>&1; then
        log_success "Xcode project is valid"
    else
        log_error "Xcode project has issues"
        return 1
    fi
    
    # Check for uncommitted changes that might affect build
    if [[ -n "$(git status --porcelain)" ]]; then
        log_warning "Uncommitted changes detected:"
        git status --short
        log_info "Consider committing changes for reproducible builds"
    else
        log_success "Working directory is clean"
    fi
}
