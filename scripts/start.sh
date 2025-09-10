#!/usr/bin/env bash

# 🏆 AFL Fantasy Platform - Simple Start Script
# This script starts the fully integrated AFL Fantasy platform

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
    echo "════════════════════════════════════════════════════════════════"
    echo "  🏆 AFL Fantasy Intelligence Platform"
    echo "════════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} ✅ $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date +%H:%M:%S)]${NC} ⚠️ $1"
}

print_error() {
    echo -e "${RED}[$(date +%H:%M:%S)]${NC} ❌ $1"
}

# Parse arguments
CLEAN=false
STATUS=false
STOP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --status)
            STATUS=true
            shift
            ;;
        --stop)
            STOP=true
            shift
            ;;
        --help|-h)
            echo "AFL Fantasy Platform - Start Script"
            echo ""
            echo "Usage: ./start.sh [options]"
            echo ""
            echo "Options:"
            echo "  --clean     Kill existing processes and clean start"
            echo "  --status    Show current application status"
            echo "  --stop      Stop the application"
            echo "  --help      Show this help"
            echo ""
            echo "This starts the complete AFL Fantasy platform including:"
            echo "  • React frontend with live data"
            echo "  • Express API backend with all routes"
            echo "  • Fantasy analysis tools and calculators"
            echo "  • Player data and statistics"
            echo "  • Real-time score projections"
            echo ""
            echo "Quick Access URLs:"
            echo "  🌐 Web App:     http://localhost:5173"
            echo "  🔧 API Health:  http://localhost:5173/api/health"
            echo "  📊 Dashboard:   http://localhost:5173/dashboard"
            echo "  🛠️ Tools:       http://localhost:5173/api/fantasy-tools"
            echo ""
            echo "iOS Integration:"
            echo "  ./run_ios.sh    Start iOS simulator and app"
            echo ""
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_header

# Handle status check
if [ "$STATUS" = true ]; then
    echo -e "${BOLD}AFL Fantasy Platform Status:${NC}"
    
    if lsof -ti:5173 &>/dev/null; then
        PID=$(lsof -ti:5173)
        print_success "Application is running (PID: $PID)"
        
        # Test endpoints
        if curl -s http://localhost:5173/api/health | grep -q "healthy" 2>/dev/null; then
            print_success "Health endpoint responding ✓"
        else
            print_warning "Health endpoint not responding"
        fi
        
        echo ""
        echo -e "${BOLD}${GREEN}Quick Access:${NC}"
        echo -e "  🌐 Web App:     ${CYAN}http://localhost:5173${NC}"
        echo -e "  🔧 API Health:  ${CYAN}http://localhost:5173/api/health${NC}"
        echo -e "  📊 Dashboard:   ${CYAN}http://localhost:5173/dashboard${NC}"
        echo -e "  🛠️ Tools:       ${CYAN}http://localhost:5173/api/fantasy-tools${NC}"
        
    else
        print_warning "Application is not running"
        echo "Use: ./start.sh to start the application"
    fi
    exit 0
fi

# Handle stop
if [ "$STOP" = true ]; then
    print_step "Stopping AFL Fantasy Platform..."
    
    if lsof -ti:5173 &>/dev/null; then
        PID=$(lsof -ti:5173)
        kill $PID 2>/dev/null && sleep 2
        print_success "Application stopped (was PID: $PID)"
    else
        print_warning "No application running on port 5173"
    fi
    exit 0
fi

# Clean existing processes if requested
if [ "$CLEAN" = true ]; then
    print_step "Cleaning existing processes..."
    
    if lsof -ti:5173 &>/dev/null; then
        lsof -ti:5173 | xargs kill -9 2>/dev/null || true
        print_success "Killed existing processes on port 5173"
        sleep 2
    fi
fi

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

print_success "Node.js $(node --version) ✓"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this from the AFL Fantasy project root."
    exit 1
fi

# Setup environment
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success "Created .env from template"
        print_warning "Edit .env with your actual API keys for full functionality"
    fi
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    print_step "Installing dependencies..."
    npm install
    print_success "Dependencies installed"
fi

# Start the application
print_step "Starting AFL Fantasy Platform..."

# Check if already running
if lsof -ti:5173 &>/dev/null; then
    print_warning "Application already running on port 5173"
    print_step "Use --clean to restart or --status to check status"
    exit 1
fi

# Function to handle cleanup on exit
cleanup() {
    print_step "Shutting down gracefully..."
    exit 0
}
trap cleanup INT TERM

print_step "Launching application (use Ctrl+C to stop)..."
npm run dev &
APP_PID=$!

# Wait for startup
sleep 4

# Verify it's running
if ps -p $APP_PID > /dev/null 2>&1 && lsof -ti:5173 &>/dev/null; then
    print_success "🎉 AFL Fantasy Platform started successfully!"
    
    echo ""
    echo -e "${BOLD}${GREEN}Platform Ready! 🚀${NC}"
    echo ""
    echo -e "${BOLD}Quick Access URLs:${NC}"
    echo -e "  🌐 Web Application:  ${CYAN}http://localhost:5173${NC}"
    echo -e "  🔧 Health Check:     ${CYAN}http://localhost:5173/api/health${NC}"
    echo -e "  📊 Dashboard:        ${CYAN}http://localhost:5173/dashboard${NC}"
    echo -e "  🛠️ Fantasy Tools:    ${CYAN}http://localhost:5173/api/fantasy-tools${NC}"
    echo ""
    echo -e "${BOLD}${YELLOW}Features Available:${NC}"
    echo -e "  • Trade analysis and optimization"
    echo -e "  • Player statistics and projections"
    echo -e "  • Team management tools"
    echo -e "  • Real-time data updates"
    echo -e "  • Advanced analytics dashboard"
    echo ""
    echo -e "${BOLD}${CYAN}iOS Development:${NC}"
    echo -e "  • Run ${YELLOW}./run_ios.sh${NC} to start iOS simulator and app"
    echo -e "  • The app will connect to this backend automatically"
    echo ""
    echo -e "${BOLD}${GREEN}Management Commands:${NC}"
    echo -e "  • ${YELLOW}./start.sh --status${NC}  - Check application status"
    echo -e "  • ${YELLOW}./start.sh --stop${NC}    - Stop the application"
    echo -e "  • ${YELLOW}./start.sh --clean${NC}   - Clean restart"
    echo ""
    print_step "Application running. Press Ctrl+C to stop."
    
    # Wait for the process
    wait $APP_PID
else
    print_error "Failed to start the application"
    print_step "Check the output above for error details"
    exit 1
fi
