#!/bin/bash

# 🛠️ AFL Fantasy Platform - First-Time Setup Script
echo "🏆 AFL Fantasy Intelligence Platform - First-Time Setup"
echo "=================================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js: $NODE_VERSION${NC}"
    
    # Check if version is >= 18
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -lt 18 ]; then
        echo -e "${YELLOW}⚠️ Warning: Node.js 18+ recommended (you have $NODE_VERSION)${NC}"
    fi
else
    echo -e "${RED}❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org${NC}"
    exit 1
fi

# Check npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✅ npm: $NPM_VERSION${NC}"
else
    echo -e "${RED}❌ npm not found. Please install Node.js which includes npm${NC}"
    exit 1
fi

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: package.json not found. Make sure you're in the AFL Fantasy project directory.${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm install

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies installed successfully${NC}"

# Setup environment file
echo -e "${BLUE}⚙️ Setting up environment configuration...${NC}"

if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️ .env file already exists${NC}"
else
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Created .env from .env.example${NC}"
    else
        echo -e "${YELLOW}⚠️ No .env.example found${NC}"
        # Create a basic .env file
        cat > .env << 'EOF'
# AFL Fantasy Platform Environment Variables

# Database Configuration
DATABASE_URL=postgresql://localhost:5432/afl_fantasy

# API Keys (replace with your actual keys)
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# Server Configuration
NODE_ENV=development
PORT=5173

# Session Secret (generate a secure random string)
SESSION_SECRET=your_session_secret_here

# AFL Fantasy Integration (optional)
AFL_FANTASY_BASE_URL=https://fantasy.afl.com.au
EOF
        echo -e "${GREEN}✅ Created basic .env file${NC}"
    fi
fi

echo -e "${BLUE}🔍 Checking database setup...${NC}"

# Check if PostgreSQL is available
if command_exists psql; then
    echo -e "${GREEN}✅ PostgreSQL client found${NC}"
else
    echo -e "${YELLOW}⚠️ PostgreSQL client not found. You may need to install PostgreSQL if using database features${NC}"
fi

echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo -e "${YELLOW}1. Edit .env file with your actual API keys and database credentials${NC}"
echo -e "${YELLOW}2. If using database features, ensure PostgreSQL is running${NC}"
echo -e "${YELLOW}3. Run './start.sh' to start the development servers${NC}"
echo ""
echo -e "${GREEN}📊 Web Dashboard: http://localhost:5173${NC}"
echo -e "${GREEN}🔌 API Endpoints: http://localhost:5173/api${NC}"
echo ""
echo -e "${BLUE}For more information, see the documentation in /docs folder${NC}"

# Open setup dashboard if available
echo ""
echo -e "${BLUE}📋 Opening enhanced setup dashboard...${NC}"
if [ -f "setup-dashboard.html" ]; then
    # Start a simple HTTP server for the dashboard to avoid CORS issues
    if command -v python3 >/dev/null 2>&1; then
        python3 -m http.server 8080 --bind 127.0.0.1 >/dev/null 2>&1 &
        DASHBOARD_SERVER_PID=$!
        sleep 2
        
        if command -v open >/dev/null 2>&1; then
            open "http://localhost:8080/setup-dashboard.html"
        elif command -v xdg-open >/dev/null 2>&1; then
            xdg-open "http://localhost:8080/setup-dashboard.html"
        else
            echo -e "${GREEN}Setup dashboard: http://localhost:8080/setup-dashboard.html${NC}"
        fi
        
        echo -e "${GREEN}✅ Enhanced setup dashboard opened${NC}"
        echo -e "${BLUE}💡 Dashboard server running on http://localhost:8080${NC}"
    else
        # Fallback to file URL
        if command -v open >/dev/null 2>&1; then
            open setup-dashboard.html
        else
            echo -e "${YELLOW}Setup dashboard available at: file://$(pwd)/setup-dashboard.html${NC}"
        fi
    fi
else
    echo -e "${RED}❌ Enhanced setup dashboard not found${NC}"
fi
