#!/usr/bin/env bash

# 📱 AFL Fantasy iOS App - Enhanced Simulator Integration
# Boots simulator, builds app, connects to local backend, and handles graceful shutdown

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
DEFAULT_SIMULATOR="iPhone 15"
API_BASE_URL="http://localhost:4000"
FRONTEND_URL="http://localhost:5173"
XCODE_PROJECT="ios/AFLFantasy.xcodeproj"
APP_SCHEME="AFLFantasy"

# Functions
print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "================================================================"
    echo "  📱 AFL Fantasy iOS App - Enhanced Launch Script"
    echo "================================================================"
    echo -e "${NC}"
}

print_section() {
    echo -e "${CYAN}${BOLD}▶ $1${NC}"
}

print_step() {
    echo -e "${BLUE}[$(date +%T)]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date +%T)]${NC} ✅ $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date +%T)]${NC} ⚠️ $1"
}

print_error() {
    echo -e "${RED}[$(date +%T)]${NC} ❌ $1"
}

print_info() {
    echo -e "${PURPLE}[$(date +%T)]${NC} ℹ️ $1"
}

# Help function
show_help() {
    cat << EOF
AFL Fantasy iOS App Launcher

USAGE:
    ./run_ios.sh [OPTIONS]

OPTIONS:
    --device        Simulator device name (default: iPhone 15)
    --xcode         Open in Xcode instead of command-line build
    --build-only    Build without running
    --clean         Clean build
    --check-api     Check API connectivity before launching
    --help, -h      Show this help message

EXAMPLES:
    ./run_ios.sh                        # Build and run on iPhone 15 simulator
    ./run_ios.sh --device "iPad Pro"    # Run on iPad Pro simulator
    ./run_ios.sh --xcode                # Open in Xcode
    ./run_ios.sh --clean                # Clean build and run
    ./run_ios.sh --check-api            # Check backend connectivity first

PREREQUISITES:
    • Xcode installed with command-line tools
    • AFL Fantasy backend running on http://localhost:4000
    • iOS Simulator available

EOF
}

# Parse command line arguments
SIMULATOR_DEVICE="$DEFAULT_SIMULATOR"
OPEN_XCODE=false
BUILD_ONLY=false
CLEAN_BUILD=false
CHECK_API=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --device)
            SIMULATOR_DEVICE="$2"
            shift 2
            ;;
        --xcode)
            OPEN_XCODE=true
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        --check-api)
            CHECK_API=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    local errors=0
    
    # Check if we're in the right directory
    if [ ! -d "ios" ]; then
        print_error "ios directory not found. Please run this from the AFL Fantasy project root."
        errors=$((errors + 1))
    else
        print_success "iOS project directory found ✓"
    fi
    
    # Check if Xcode is available
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode not found. Please install Xcode from the App Store."
        errors=$((errors + 1))
    else
        local xcode_version=$(xcodebuild -version | head -n 1 | cut -d' ' -f2)
        print_success "Xcode $xcode_version ✓"
    fi
    
    # Check if xcodeproj exists
    if [ ! -d "$XCODE_PROJECT" ]; then
        print_error "AFLFantasy.xcodeproj not found in ios/ directory."
        errors=$((errors + 1))
    else
        print_success "Xcode project found ✓"
    fi
    
    # Check simulator availability
    if ! xcrun simctl list devices | grep -q "iOS"; then
        print_error "No iOS simulators found. Please install iOS Simulator."
        errors=$((errors + 1))
    else
        print_success "iOS Simulators available ✓"
    fi
    
    if [ $errors -gt 0 ]; then
        print_error "Prerequisites check failed with $errors errors"
        exit 1
    fi
}

# Check API connectivity
check_api_connectivity() {
    print_section "Checking Backend Connectivity"
    
    local api_endpoints=("$API_BASE_URL/api/health" "$FRONTEND_URL")
    local api_healthy=false
    
    for endpoint in "${api_endpoints[@]}"; do
        print_step "Checking $endpoint..."
        if curl -sf "$endpoint" > /dev/null 2>&1; then
            print_success "✓ $endpoint is responding"
            api_healthy=true
        else
            print_warning "⚠️ $endpoint is not responding"
        fi
    done
    
    if [ "$api_healthy" = false ]; then
        print_warning "Backend APIs are not responding"
        print_info "Start the backend with: ./setup.sh --dev"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Cancelled by user"
            exit 0
        fi
    else
        print_success "Backend connectivity verified ✓"
    fi
}

# Boot simulator
boot_simulator() {
    print_section "Setting up iOS Simulator"
    
    # Find the simulator device ID
    local device_id=$(xcrun simctl list devices | grep "$SIMULATOR_DEVICE" | grep -v "unavailable" | head -1 | grep -o '([^)]*)' | tr -d '()')
    
    if [ -z "$device_id" ]; then
        print_error "Simulator '$SIMULATOR_DEVICE' not found"
        print_info "Available simulators:"
        xcrun simctl list devices | grep -E "iPhone|iPad" | grep -v "unavailable" | sed 's/^/  /'
        exit 1
    fi
    
    print_step "Using simulator: $SIMULATOR_DEVICE ($device_id)"
    
    # Check if simulator is already booted
    local device_state=$(xcrun simctl list devices | grep "$device_id" | grep -o "Booted\|Shutdown")
    
    if [ "$device_state" != "Booted" ]; then
        print_step "Booting simulator..."
        xcrun simctl boot "$device_id"
        sleep 3
        print_success "Simulator booted ✓"
    else
        print_success "Simulator already booted ✓"
    fi
    
    # Open Simulator.app if not running
    if ! pgrep -f "Simulator.app" > /dev/null; then
        print_step "Opening Simulator app..."
        open -a Simulator
        sleep 2
    fi
    
    export SIMULATOR_DEVICE_ID="$device_id"
}

# Build and run app
build_and_run_app() {
    print_section "Building iOS App"
    
    cd ios
    
    local build_args=(
        "-scheme" "$APP_SCHEME"
        "-destination" "platform=iOS Simulator,name=$SIMULATOR_DEVICE"
        "-configuration" "Debug"
    )
    
    if [ "$CLEAN_BUILD" = true ]; then
        print_step "Performing clean build..."
        build_args+=("clean" "build")
    else
        build_args+=("build")
    fi
    
    print_step "Building for $SIMULATOR_DEVICE..."
    if xcodebuild "${build_args[@]}"; then
        print_success "Build completed successfully ✓"
    else
        print_error "Build failed"
        exit 1
    fi
    
    if [ "$BUILD_ONLY" = false ]; then
        print_step "Installing and launching app..."
        
        # Install the app
        local app_path=$(find ~/Library/Developer/Xcode/DerivedData -name "*.app" -path "*/Build/Products/Debug-iphonesimulator/*AFLFantasy.app" | head -1)
        
        if [ -n "$app_path" ]; then
            xcrun simctl install "$SIMULATOR_DEVICE_ID" "$app_path"
            
            # Launch the app
            local bundle_id=$(defaults read "$app_path/Info" CFBundleIdentifier 2>/dev/null || echo "com.aflFantasy.app")
            xcrun simctl launch "$SIMULATOR_DEVICE_ID" "$bundle_id"
            
            print_success "App launched in simulator ✓"
        else
            print_warning "Could not find built app to install"
        fi
    fi
    
    cd ..
}

# Open in Xcode
open_in_xcode() {
    print_section "Opening in Xcode"
    
    print_step "Opening $XCODE_PROJECT in Xcode..."
    open "$XCODE_PROJECT"
    
    print_success "Xcode opened ✓"
    print_info "Press ⌘+R in Xcode to build and run the app"
}

# Cleanup function
cleanup() {
    print_info "Cleaning up..."
    # Could add cleanup logic here if needed
    exit 0
}
trap cleanup INT TERM

# Main execution
main() {
    print_header
    
    # Check prerequisites
    check_prerequisites
    
    # Check API connectivity if requested
    if [ "$CHECK_API" = true ]; then
        check_api_connectivity
    fi
    
    # Handle Xcode option
    if [ "$OPEN_XCODE" = true ]; then
        open_in_xcode
        exit 0
    fi
    
    # Boot simulator and build/run app
    boot_simulator
    build_and_run_app
    
    # Show final status
    echo ""
    print_section "🎉 iOS App Setup Complete!"
    
    echo -e "${BOLD}${GREEN}Status:${NC}"
    echo -e "  📱 Simulator: ${CYAN}$SIMULATOR_DEVICE${NC} (running)"
    echo -e "  📦 App: ${CYAN}$APP_SCHEME${NC} (installed)"
    
    if [ "$BUILD_ONLY" = false ]; then
        echo -e "  🚀 Launch: ${GREEN}App is running in simulator${NC}"
    else
        echo -e "  🔨 Build: ${GREEN}Build completed (not launched)${NC}"
    fi
    
    echo -e "\n${BOLD}${YELLOW}Backend Integration:${NC}"
    echo -e "  🌐 API Endpoint:  ${CYAN}$API_BASE_URL${NC}"
    echo -e "  🎯 Frontend URL:  ${CYAN}$FRONTEND_URL${NC}"
    echo -e "  🔗 Health Check:  ${CYAN}$API_BASE_URL/api/health${NC}"
    
    echo -e "\n${BOLD}${PURPLE}Next Steps:${NC}"
    echo -e "  • Configure AFL Fantasy credentials in the app"
    echo -e "  • Ensure backend is running: ${CYAN}./setup.sh --dev${NC}"
    echo -e "  • View app logs in Xcode Console"
    echo -e "  • Use simulator menu: ${CYAN}Device → Shake${NC} for development options"
    
    echo -e "\n${PURPLE}ℹ️  App is now running in iOS Simulator${NC}"
}

# Run main function
main "$@"
