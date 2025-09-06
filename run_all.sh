#!/usr/bin/env bash

# 🚀 AFL Fantasy Platform - Development Wrapper
# Simple alias to the new setup.sh orchestrator with development mode
# This script maintains backward compatibility while using the new architecture

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
print_info "This is now a wrapper for the new setup.sh orchestrator"
echo ""

# Check if setup.sh exists
if [ ! -f "$SCRIPT_DIR/setup.sh" ]; then
    print_warning "setup.sh not found - falling back to legacy mode"
    # Could fall back to old implementation here
    exit 1
fi

# Parse any arguments passed to this script
SETUP_ARGS=("--dev")

# Handle legacy arguments
for arg in "$@"; do
    case $arg in
        --clean)
            SETUP_ARGS+=("--clean")
            ;;
        --logs)
            SETUP_ARGS+=("--logs")
            ;;
        --help|-h)
            echo "AFL Fantasy Platform - Development Startup"
            echo ""
            echo "This script starts the AFL Fantasy platform in development mode with:"
            echo "  • Frontend (React with hot-reload)"
            echo "  • Backend API (Express with auto-restart)"
            echo "  • Python AI services"
            echo "  • PostgreSQL and Redis databases"
            echo "  • Real-time monitoring"
            echo ""
            echo "Options:"
            echo "  --clean    Clean rebuild (removes containers and volumes)"
            echo "  --logs     Show logs after startup"
            echo "  --help     Show this help"
            echo ""
            echo "Quick Access URLs:"
            echo "  🌐 Frontend:     http://localhost:5173"
            echo "  🔧 API Health:   http://localhost:4000/api/health"
            echo "  📊 Dashboard:    http://localhost:8090"
            echo ""
            echo "iOS Development:"
            echo "  ./run_ios.sh     Start iOS simulator and app"
            echo ""
            exit 0
            ;;
    esac
done

# Call the new setup orchestrator
print_info "Calling setup orchestrator with development configuration..."
print_success "Running: ./setup.sh ${SETUP_ARGS[*]}"
echo ""

exec "$SCRIPT_DIR/setup.sh" "${SETUP_ARGS[@]}"
