#!/bin/bash

# 🚀 AFL Fantasy Platform - Complete Startup Script
# Starts all services: Web Frontend, API Backend, Python AI Services, and optionally iOS Simulator

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
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

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this script from the AFL Fantasy project root."
    exit 1
fi

print_status "🏆 Starting AFL Fantasy Intelligence Platform"
echo -e "${BLUE}=====================================${NC}"

# Check prerequisites
print_status "🔍 Checking prerequisites..."

if ! command -v node &> /dev/null; then
    print_error "Node.js not found. Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    print_error "npm not found. Please install Node.js which includes npm"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_warning "Node.js version $NODE_VERSION detected. Version 18+ recommended."
fi

print_success "Node.js $(node --version) ✓"
print_success "npm $(npm --version) ✓"

# Check Python (optional)
if command -v python3 &> /dev/null; then
    print_success "Python $(python3 --version | cut -d' ' -f2) ✓"
else
    print_warning "Python not found. AI services may not work."
fi

# Check Xcode (for iOS development)
if command -v xcodebuild &> /dev/null; then
    print_success "Xcode development tools ✓"
else
    print_warning "Xcode not found. iOS development unavailable."
fi

# Setup environment
print_status "⚙️ Setting up environment..."

if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success "Created .env from .env.example"
    else
        # Create basic .env
        cat > .env << 'EOF'
# AFL Fantasy Platform Environment Variables
NODE_ENV=development
PORT=5173
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
DATABASE_URL=postgresql://localhost:5432/afl_fantasy
EOF
        print_success "Created basic .env file"
    fi
    print_warning "Please edit .env with your actual API keys"
fi

# Install dependencies
print_status "📦 Installing dependencies..."
if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
    npm install
    print_success "Dependencies installed"
else
    print_success "Dependencies already up to date"
fi

# Create log directory
mkdir -p logs

# Function to kill processes on exit
cleanup() {
    print_status "🛑 Shutting down services..."
    jobs -p | xargs -r kill
    exit 0
}
trap cleanup EXIT INT TERM

# Start the main application (Web + API)
print_status "🌐 Starting Web Frontend + API Backend..."
npm run dev > logs/webapp.log 2>&1 &
WEBAPP_PID=$!

# Wait a bit for the server to start
sleep 3

# Check if web app started successfully
if ps -p $WEBAPP_PID > /dev/null; then
    print_success "Web Frontend + API Backend started (PID: $WEBAPP_PID)"
    print_success "Web Dashboard: http://localhost:5173"
    print_success "API Health Check: http://localhost:5173/api/health"
else
    print_error "Failed to start Web Frontend + API Backend"
    print_error "Check logs/webapp.log for details"
    exit 1
fi

# Start Python AI services (if available)
if [ -f "backend/python/main.py" ] && command -v python3 &> /dev/null; then
    print_status "🤖 Starting Python AI Services..."
    cd backend/python
    
    # Install Python dependencies if requirements.txt exists
    if [ -f "requirements.txt" ]; then
        print_status "Installing Python dependencies..."
        pip3 install -r requirements.txt > ../../logs/python_install.log 2>&1 || {
            print_warning "Failed to install Python dependencies. Check logs/python_install.log"
        }
    fi
    
    # Start Python services
    python3 main.py > ../../logs/python_ai.log 2>&1 &
    PYTHON_PID=$!
    cd ../..
    
    sleep 2
    if ps -p $PYTHON_PID > /dev/null; then
        print_success "Python AI Services started (PID: $PYTHON_PID)"
    else
        print_warning "Python AI Services failed to start. Check logs/python_ai.log"
    fi
else
    print_warning "Python AI Services not available (missing main.py or Python)"
fi

# Optional: Start PostgreSQL (if Docker is available)
if command -v docker &> /dev/null && [ -f "docker-compose.yml" ]; then
    print_status "🐘 Checking PostgreSQL..."
    if ! docker ps | grep -q postgres; then
        print_status "Starting PostgreSQL container..."
        docker-compose up postgres -d > logs/postgres.log 2>&1 &
        sleep 5
        print_success "PostgreSQL started"
    else
        print_success "PostgreSQL already running"
    fi
elif command -v psql &> /dev/null; then
    print_status "🐘 PostgreSQL detected locally"
    # Check if afl_fantasy database exists
    if psql -lqt | cut -d \| -f 1 | grep -qw afl_fantasy; then
        print_success "Database 'afl_fantasy' exists"
    else
        print_warning "Database 'afl_fantasy' not found. You may need to run: createdb afl_fantasy"
    fi
else
    print_warning "PostgreSQL not available (Docker or local). Database features disabled."
fi

# iOS App Instructions
echo ""
print_status "📱 iOS App Setup:"
if command -v xcodebuild &> /dev/null; then
    print_success "To start iOS app:"
    echo -e "   ${GREEN}1.${NC} Open: ${YELLOW}open ios/AFLFantasy.xcodeproj${NC}"
    echo -e "   ${GREEN}2.${NC} Press ⌘+R to build and run in iOS Simulator"
    echo -e "   ${GREEN}3.${NC} Or use command line: ${YELLOW}cd ios && xcodebuild -scheme AFLFantasy -destination 'platform=iOS Simulator,name=iPhone 15' build${NC}"
else
    print_warning "Xcode not available. iOS development disabled."
fi

# Summary
echo ""
print_success "🎉 AFL Fantasy Platform is starting up!"
echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}Services Status:${NC}"
echo -e "  • Web Dashboard: ${GREEN}http://localhost:5173${NC}"
echo -e "  • API Endpoints: ${GREEN}http://localhost:5173/api${NC}"
echo -e "  • Health Check:  ${GREEN}http://localhost:5173/api/health${NC}"
echo -e "  • Logs Directory: ${YELLOW}./logs/${NC}"

if ps -p $WEBAPP_PID > /dev/null; then
    echo -e "  • Web + API: ${GREEN}Running${NC} (PID: $WEBAPP_PID)"
fi

if [ ! -z "$PYTHON_PID" ] && ps -p $PYTHON_PID > /dev/null; then
    echo -e "  • Python AI: ${GREEN}Running${NC} (PID: $PYTHON_PID)"
fi

echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo -e "  • Press ${RED}Ctrl+C${NC} to stop all services"
echo -e "  • Check ${YELLOW}./logs/${NC} directory for detailed logs"
echo -e "  • Edit ${YELLOW}.env${NC} to configure API keys"
echo -e "  • Visit ${YELLOW}http://localhost:5173/api/health${NC} to verify API status"

# Wait for services and show periodic status
print_status "🔄 Services running. Press Ctrl+C to stop all services."

# Periodic health checks
while true; do
    sleep 30
    
    # Check if main webapp is still running
    if ! ps -p $WEBAPP_PID > /dev/null; then
        print_error "Web Frontend + API Backend has stopped unexpectedly"
        print_error "Check logs/webapp.log for details"
        exit 1
    fi
    
    # Optional: Check API health
    if command -v curl &> /dev/null; then
        if curl -sf http://localhost:5173/api/health > /dev/null 2>&1; then
            # Health check passed
            :
        else
            print_warning "API health check failed"
        fi
    fi
done
