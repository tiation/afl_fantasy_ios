#!/usr/bin/env bash

# 🚀 AFL Fantasy Platform - Development Wrapper
# Simple alias to the working start.sh script
# This script maintains backward compatibility

set -euo pipefail

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

print_info() {
    echo -e "${CYAN}${BOLD}[run_all]${NC} $1"
}

print_success() {
    echo -e "${GREEN}${BOLD}[run_all]${NC} ✅ $1"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}[run_all]${NC} ⚠️ $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_info "🏆 AFL Fantasy Platform - Development Mode"
print_info "This now uses the working start.sh script"
echo ""

# Check if start.sh exists
if [ ! -f "$SCRIPT_DIR/start.sh" ]; then
    print_warning "start.sh not found - please use npm run dev directly"
    exit 1
fi

# Parse any arguments passed to this script
START_ARGS=()

# Handle legacy arguments
for arg in "$@"; do
    case $arg in
        --clean)
            START_ARGS+=("--clean")
            ;;
        --logs)
            # start.sh doesn't need logs flag, it shows output by default
            ;;
        --help|-h)
            echo "AFL Fantasy Platform - Development Startup"
            echo ""
            echo "This script starts the AFL Fantasy platform with:"
            echo "  • React frontend with live data"
            echo "  • Express API backend with all routes"
            echo "  • Fantasy analysis tools and calculators"
            echo "  • Player data and statistics"
            echo "  • Real-time score projections"
            echo ""
            echo "Options:"
            echo "  --clean    Kill existing processes and clean start"
            echo "  --help     Show this help"
            echo ""
            echo "Quick Access URLs:"
            echo "  🌐 Web App:     http://localhost:5173"
            echo "  🔧 API Health:  http://localhost:5173/api/health"
            echo "  📊 Dashboard:   http://localhost:5173/dashboard"
            echo "  🛠️ Tools:       http://localhost:5173/api/fantasy-tools"
            echo ""
            echo "iOS Development:"
            echo "  ./run_ios.sh    Start iOS simulator and app"
            echo ""
            exit 0
            ;;
    esac
done

# Call the working start script
print_info "Starting AFL Fantasy Platform..."
print_success "Running: ./start.sh ${START_ARGS[*]}"
echo ""

exec "$SCRIPT_DIR/start.sh" "${START_ARGS[@]}"
