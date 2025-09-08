#!/usr/bin/env bash
# AFL Fantasy iOS - Comprehensive Build Script
# Enterprise-grade build system with quality gates and multi-configuration support

set -euo pipefail

# Get script directory for relative imports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source quality gates library
# shellcheck source=lib_quality.sh
source "$SCRIPT_DIR/lib_quality.sh"

# Default configuration
DEFAULT_SCHEME="AFLFantasy"
DEFAULT_CONFIGURATION="Debug"
DEFAULT_DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=18.6"
DEFAULT_COVERAGE_THRESHOLD=80
DEFAULT_OUTPUT_PATH="$PROJECT_ROOT/build"

# Global variables
SCHEME="$DEFAULT_SCHEME"
CONFIGURATION="$DEFAULT_CONFIGURATION"
DESTINATION="$DEFAULT_DESTINATION"
COVERAGE_THRESHOLD="$DEFAULT_COVERAGE_THRESHOLD"
OUTPUT_PATH="$DEFAULT_OUTPUT_PATH"
SKIP_TESTS=false
SKIP_QUALITY=false
SKIP_PERFORMANCE=false
CLEAN_BUILD=false
VERBOSE=false
ARCHIVE_APP=false

# Cleanup function
cleanup() {
    if [[ "${CLEAN_ON_EXIT:-false}" == "true" ]]; then
        log_info "Cleaning up on exit..."
        clean_build_artifacts
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Usage function
show_help() {
cat << EOF
AFL Fantasy iOS Build Script

USAGE:
    bash Scripts/build.sh [OPTIONS]

OPTIONS:
    -c, --configuration CONFIG    Build configuration (Debug|Release) [default: $DEFAULT_CONFIGURATION]
    -d, --destination DEST        Build destination [default: "$DEFAULT_DESTINATION"]
    -s, --scheme SCHEME          Xcode scheme [default: $DEFAULT_SCHEME]
    -o, --output PATH            Output path for archives [default: $DEFAULT_OUTPUT_PATH]
    -g, --coverage-threshold N    Coverage threshold percentage [default: $DEFAULT_COVERAGE_THRESHOLD]
    -t, --skip-tests             Skip running tests
    -q, --skip-quality           Skip quality gates (formatting, linting)
    -p, --skip-performance       Skip performance budget checks
    -a, --archive                Create archive and export IPA (Release only)
    --clean                      Clean build artifacts before building
    --verbose                    Enable verbose output
    -h, --help                   Show this help message

EXAMPLES:
    # Basic debug build with tests
    bash Scripts/build.sh

    # Release build without tests
    bash Scripts/build.sh -c Release -t

    # Build and archive for distribution
    bash Scripts/build.sh -c Release -a -t

    # Build for specific device
    bash Scripts/build.sh -d "platform=iOS,name=My iPhone"

    # Fast build skipping quality checks
    bash Scripts/build.sh -q -p -t

    # Full enterprise build
    bash Scripts/build.sh -c Release -a --clean -g 85

PREREQUISITES:
    - Xcode 16.0+
    - SwiftFormat: brew install swiftformat
    - SwiftLint: brew install swiftlint
    - Ruby gems: xcpretty (auto-installed)

QUALITY GATES:
    - Code formatting (SwiftFormat)
    - Linting (SwiftLint)
    - Unit tests with coverage
    - Performance budget validation

BUILD ARTIFACTS:
    - Debug: $DEFAULT_OUTPUT_PATH/Debug-iphonesimulator/
    - Release Archive: $DEFAULT_OUTPUT_PATH/AFLFantasy.xcarchive
    - Release IPA: $DEFAULT_OUTPUT_PATH/AFLFantasy.ipa

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--configuration)
                CONFIGURATION="$2"
                shift 2
                ;;
            -d|--destination)
                DESTINATION="$2"
                shift 2
                ;;
            -s|--scheme)
                SCHEME="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_PATH="$2"
                shift 2
                ;;
            -g|--coverage-threshold)
                COVERAGE_THRESHOLD="$2"
                shift 2
                ;;
            -t|--skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            -q|--skip-quality)
                SKIP_QUALITY=true
                shift
                ;;
            -p|--skip-performance)
                SKIP_PERFORMANCE=true
                shift
                ;;
            -a|--archive)
                ARCHIVE_APP=true
                shift
                ;;
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Validate arguments
validate_args() {
    # Validate configuration
    if [[ "$CONFIGURATION" != "Debug" && "$CONFIGURATION" != "Release" ]]; then
        log_error "Invalid configuration: $CONFIGURATION. Must be Debug or Release"
        exit 1
    fi
    
    # Archive only works with Release
    if [[ "$ARCHIVE_APP" == "true" && "$CONFIGURATION" != "Release" ]]; then
        log_error "Archive can only be created with Release configuration"
        exit 1
    fi
    
    # Validate coverage threshold
    if [[ ! "$COVERAGE_THRESHOLD" =~ ^[0-9]+$ ]] || [[ "$COVERAGE_THRESHOLD" -lt 0 ]] || [[ "$COVERAGE_THRESHOLD" -gt 100 ]]; then
        log_error "Invalid coverage threshold: $COVERAGE_THRESHOLD. Must be 0-100"
        exit 1
    fi
}

# Build the project
build_project() {
    log_section "Building AFL Fantasy iOS"
    
    log_info "Configuration: $CONFIGURATION"
    log_info "Destination: $DESTINATION" 
    log_info "Scheme: $SCHEME"
    log_info "Output: $OUTPUT_PATH"
    
    # Create output directory
    mkdir -p "$OUTPUT_PATH"
    
    # Set enterprise build flags
    local xcodebuild_settings=()
    if [[ "$CONFIGURATION" == "Release" ]]; then
        xcodebuild_settings+=(
            "SWIFT_TREAT_WARNINGS_AS_ERRORS=YES"
            "ENABLE_STRICT_CONCURRENCY=complete"
            "ENABLE_TESTABILITY=NO"
            "DEBUG_INFORMATION_FORMAT=dwarf-with-dsym"
        )
    fi
    
    # Build command based on whether we're archiving
    if [[ "$ARCHIVE_APP" == "true" ]]; then
        if [[ ${#xcodebuild_settings[@]} -gt 0 ]]; then
            build_and_archive "${xcodebuild_settings[@]}"
        else
            build_and_archive
        fi
    else
        if [[ ${#xcodebuild_settings[@]} -gt 0 ]]; then
            build_for_testing "${xcodebuild_settings[@]}"
        else
            build_for_testing
        fi
    fi
}

# Build for testing/development
build_for_testing() {
    local settings=("$@")
    
    log_info "Building for testing/development..."
    
    local xcodebuild_cmd=(
        xcodebuild
        -scheme "$SCHEME"
        -configuration "$CONFIGURATION"
        -destination "$DESTINATION"
        -derivedDataPath "$OUTPUT_PATH/DerivedData"
        build
    )
    
    # Add settings if any provided
    if [[ $# -gt 0 ]]; then
        for setting in "${settings[@]}"; do
            xcodebuild_cmd+=("$setting")
        done
    fi
    
    # Execute build
    if [[ "$VERBOSE" == "true" ]]; then
        log_info "Executing: ${xcodebuild_cmd[*]}"
    fi
    
    if command -v xcpretty >/dev/null 2>&1; then
        "${xcodebuild_cmd[@]}" | xcpretty
    else
        "${xcodebuild_cmd[@]}"
    fi
    
    log_success "Build completed successfully"
}

# Build and archive for distribution
build_and_archive() {
    local settings=("$@")
    
    log_info "Building and archiving for distribution..."
    
    local archive_path="$OUTPUT_PATH/AFLFantasy.xcarchive"
    
    # Archive command
    local xcodebuild_cmd=(
        xcodebuild
        -scheme "$SCHEME"
        -configuration "$CONFIGURATION"
        -archivePath "$archive_path"
        -derivedDataPath "$OUTPUT_PATH/DerivedData"
        archive
    )
    
    # Add settings if any provided
    if [[ $# -gt 0 ]]; then
        for setting in "${settings[@]}"; do
            xcodebuild_cmd+=("$setting")
        done
    fi
    
    # Execute archive
    if [[ "$VERBOSE" == "true" ]]; then
        log_info "Executing: ${xcodebuild_cmd[*]}"
    fi
    
    if command -v xcpretty >/dev/null 2>&1; then
        "${xcodebuild_cmd[@]}" | xcpretty
    else
        "${xcodebuild_cmd[@]}"
    fi
    
    log_success "Archive created: $archive_path"
    
    # Export IPA
    export_ipa "$archive_path"
}

# Export IPA from archive
export_ipa() {
    local archive_path="$1"
    local ipa_path="$OUTPUT_PATH/AFLFantasy.ipa"
    
    log_info "Exporting IPA..."
    
    # Create export options plist
    local export_plist="$OUTPUT_PATH/ExportOptions.plist"
    create_export_options_plist "$export_plist"
    
    # Export command
    xcodebuild \
        -exportArchive \
        -archivePath "$archive_path" \
        -exportPath "$OUTPUT_PATH" \
        -exportOptionsPlist "$export_plist" \
        -allowProvisioningUpdates
    
    # Find the exported IPA (Xcode creates a subfolder)
    local exported_ipa
    exported_ipa=$(find "$OUTPUT_PATH" -name "*.ipa" | head -n1)
    
    if [[ -n "$exported_ipa" && "$exported_ipa" != "$ipa_path" ]]; then
        mv "$exported_ipa" "$ipa_path"
    fi
    
    if [[ -f "$ipa_path" ]]; then
        log_success "IPA exported: $ipa_path"
        
        # Show IPA size
        local ipa_size
        ipa_size=$(du -h "$ipa_path" | cut -f1)
        log_info "IPA size: $ipa_size"
    else
        log_error "Failed to export IPA"
        return 1
    fi
}

# Create export options plist
create_export_options_plist() {
    local plist_path="$1"
    
    cat > "$plist_path" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>YLWMNJMZZ3</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF
}

# Print build summary
print_build_summary() {
    log_section "Build Summary"
    
    log_info "Project: AFL Fantasy iOS"
    log_info "Configuration: $CONFIGURATION"
    log_info "Scheme: $SCHEME"
    log_info "Destination: $DESTINATION"
    
    if [[ "$SKIP_QUALITY" == "false" ]]; then
        log_success "Quality gates: PASSED"
    else
        log_warning "Quality gates: SKIPPED"
    fi
    
    if [[ "$SKIP_TESTS" == "false" ]]; then
        log_success "Tests: PASSED"
    else
        log_warning "Tests: SKIPPED"
    fi
    
    if [[ -d "$OUTPUT_PATH" ]]; then
        log_info "Build artifacts:"
        find "$OUTPUT_PATH" -name "*.app" -o -name "*.xcarchive" -o -name "*.ipa" | while read -r artifact; do
            local size
            size=$(du -h "$artifact" | cut -f1)
            log_info "  $(basename "$artifact") - $size"
        done
    fi
    
    log_success "🎉 Build completed successfully!"
    log_info "Output path: $OUTPUT_PATH"
}

# Main function
main() {
    # Change to project root
    cd "$PROJECT_ROOT"
    
    log_section "AFL Fantasy iOS Build System"
    log_info "Starting build process..."
    
    # Parse arguments
    parse_args "$@"
    validate_args
    
    # Clean if requested
    if [[ "$CLEAN_BUILD" == "true" ]]; then
        clean_build_artifacts
        CLEAN_ON_EXIT=true
    fi
    
    # Validate project health
    validate_project_health
    
    # Run quality gates unless skipped
    if [[ "$SKIP_QUALITY" == "false" ]]; then
        if [[ "$SKIP_TESTS" == "false" ]]; then
            run_all_quality_gates "$COVERAGE_THRESHOLD" "$SCHEME" "$DESTINATION"
        else
            # Run quality gates without tests
            check_prerequisites
            run_swiftformat
            run_swiftlint
        fi
    fi
    
    # Performance budget check
    if [[ "$SKIP_PERFORMANCE" == "false" ]]; then
        check_performance_budget || log_warning "Performance budget check failed"
    fi
    
    # Build project
    build_project
    
    # Print summary
    print_build_summary
}

# Run main function with all arguments
main "$@"
