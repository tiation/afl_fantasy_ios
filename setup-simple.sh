#!/usr/bin/env bash

# AFL Fantasy Platform - Simple Working Setup
# Uses the existing npm dev setup that already works

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "════════════════════════════════════════════════"
    echo "  🏆 AFL Fantasy Platform - Quick Start"
    echo "════════════════════════════════════════════════"
    echo -e "${NC}"
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

# Parse arguments
CLEAN=false
LOGS=false

for arg in "$@"; do
    case $arg in
        --clean)
            CLEAN=true
            shift
            ;;
        --logs)
            LOGS=true
            shift
            ;;
        --help|-h)
            echo "AFL Fantasy Platform - Simple Setup"
            echo ""
            echo "Usage: ./setup-simple.sh [options]"
            echo ""
            echo "Options:"
            echo "  --clean    Kill any existing processes and clean start"
            echo "  --logs     Show verbose logging"
            echo "  --help     Show this help"
            echo ""
            echo "This starts the existing Node.js application that includes:"
            echo "  • React frontend"
            echo "  • Express API backend"
            echo "  • Fantasy tools and data processing"
            echo ""
            echo "Access URLs:"
            echo "  🌐 Application: http://localhost:5173"
            echo "  🔧 API Health:  http://localhost:5173/api/health"
            echo ""
            exit 0
            ;;
    esac
done

print_header

# Check prerequisites
print_step "Checking prerequisites..."

if ! command -v node &> /dev/null; then
    print_error "Node.js not found. Please install Node.js 18+"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    print_error "npm not found"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_warning "Node.js version $NODE_VERSION detected. Version 18+ recommended."
fi

print_success "Node.js $(node --version) ✓"
print_success "npm $(npm --version) ✓"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this from the AFL Fantasy project root."
    exit 1
fi

# Clean existing processes if requested
if [ "$CLEAN" = true ]; then
    print_step "Cleaning existing processes..."
    
    # Kill any existing Node processes on port 5173
    if lsof -ti:5173 &>/dev/null; then
        lsof -ti:5173 | xargs kill -9 2>/dev/null || true
        print_success "Killed existing processes on port 5173"
        sleep 2
    fi
fi

# Setup environment
print_step "Setting up environment..."

if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success "Created .env from .env.example"
        print_warning "Please edit .env with your actual API keys"
    else
        print_warning "No .env file found. The app will use default settings."
    fi
else
    print_success "Environment file found ✓"
fi

# Install dependencies if needed
if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
    print_step "Installing dependencies..."
    npm install
    print_success "Dependencies installed"
else
    print_success "Dependencies up to date ✓"
fi

# Create logs directory
mkdir -p logs

# Function to handle cleanup on exit
cleanup() {
    print_step "Shutting down..."
    exit 0
}
trap cleanup INT TERM

# Start the application
print_step "Starting AFL Fantasy Platform..."

if [ "$LOGS" = true ]; then
    print_step "Starting with verbose logging..."
    npm run dev
else
    print_step "Starting application (use Ctrl+C to stop)..."
    npm run dev &
    APP_PID=$!
    
    # Wait a moment for startup
    sleep 3
    
    # Check if the app started successfully
    if ps -p $APP_PID > /dev/null 2>&1; then
        print_success "Application started successfully!"
        
        echo ""
        echo -e "${BOLD}${GREEN}🎉 AFL Fantasy Platform is now running!${NC}"
        echo ""
        echo -e "${BOLD}Quick Access:${NC}"
        echo -e "  🌐 Web Application: ${CYAN}http://localhost:5173${NC}"
        echo -e "  🔧 API Health Check: ${CYAN}http://localhost:5173/api/health${NC}"
        echo -e "  📊 Fantasy Tools: ${CYAN}http://localhost:5173/api/fantasy-tools${NC}"
        echo ""
        echo -e "${BOLD}${YELLOW}Management:${NC}"
        echo -e "  • Press ${RED}Ctrl+C${NC} to stop the application"
        echo -e "  • Check ${YELLOW}./logs/${NC} for detailed logs"
        echo -e "  • Use ${YELLOW}./run_ios.sh${NC} to start iOS app"
        echo ""
        echo -e "${BOLD}${CYAN}Features Available:${NC}"
        echo -e "  • Trade analysis and suggestions"
        echo -e "  • Player statistics and projections"
        echo -e "  • Fantasy team management"
        echo -e "  • Real-time data updates"
        echo ""
        
        # Wait for the process
        wait $APP_PID
    else
        print_error "Failed to start the application"
        exit 1
    fi
fi
