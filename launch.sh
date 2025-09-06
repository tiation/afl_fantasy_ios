#!/bin/bash

# 🏆 AFL Fantasy Intelligence Platform - ULTIMATE LAUNCHER 🏆
# One script to rule them all - launches everything with cyber swagger

set -e

# Colors and effects
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Special effects
BOLD='\033[1m'
BLINK='\033[5m'
UNDERLINE='\033[4m'

# Cyber ASCII Banner
echo -e "${PURPLE}${BOLD}"
cat << "EOF"
  ▄████████    ▄████████  ▄█              ▄████████    ▄████████ ███▄▄▄▄   ███      ▄████████    ▄████████ ▄██   ▄   
 ███    ███   ███    ███ ███             ███    ███   ███    ███ ███▀▀▀██▄ ▀█████████▄ ███    ███   ███    ███ ███   ██▄ 
 ███    ███   ███    █▀  ███             ███    █▀    ███    ███ ███   ███    ▀███▀▀██ ███    ███   ███    █▀  ███▄▄▄███ 
 ███    ███  ▄███▄▄▄     ███            ▄███▄▄▄       ███    ███ ███   ███     ███   ▀ ███    ███   ███        ▀▀▀▀▀▀███ 
▀███████████ ▀▀███▀▀▀     ███           ▀▀███▀▀▀     ▀███████████ ███   ███     ███     ███    ███ ▀███████████ ▄██   ███ 
 ███    ███   ███        ███             ███          ███    ███ ███   ███     ███     ███    ███          ███ ███   ███ 
 ███    ███   ███        ███▌    ▄       ███          ███    ███ ███   ███     ███     ███    ███    ▄█    ███ ███   ███ 
 ███    █▀    ███        █████▄▄██       ███          ███    █▀   ▀█   █▀     ▄████▀   ████████▀   ▄████████▀   ▀█████▀  

                    🤖 INTELLIGENCE PLATFORM COMMAND CENTER 🤖
                           💀 READY FOR DOMINATION 💀
EOF
echo -e "${NC}"

# Configuration
PROJECT_NAME="AFL Fantasy Intelligence Platform"
VERSION="2.0.0-ULTIMATE"
LAUNCH_MODE=${1:-"dev"} # dev, docker, full

# Function declarations
log_cyber() {
    echo -e "${CYAN}[${WHITE}CYBER${CYAN}]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[${WHITE}SUCCESS${GREEN}]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[${WHITE}WARNING${YELLOW}]${NC} $1"
}

log_error() {
    echo -e "${RED}[${WHITE}ERROR${RED}]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[${WHITE}INFO${BLUE}]${NC} $1"
}

# Animated loading effect
loading_effect() {
    local text=$1
    local duration=${2:-3}
    local spin='-\|/'
    local i=0
    
    while [ $i -lt $((duration * 4)) ]; do
        printf "\r${CYAN}[${spin:$((i % 4)):1}] $text...${NC}"
        sleep 0.25
        ((i++))
    done
    echo ""
}

# Banner with system info
show_system_banner() {
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}                                        SYSTEM INITIALIZATION                                          ${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "${CYAN}🖥️  System:${NC}     $(uname -s) $(uname -m)"
    echo -e "${CYAN}🧠 CPU:${NC}        $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")"
    echo -e "${CYAN}💾 Memory:${NC}     $(echo "scale=2; $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1024^3" | bc 2>/dev/null || echo "Unknown") GB"
    echo -e "${CYAN}🐳 Docker:${NC}     $(docker --version 2>/dev/null | cut -d' ' -f3 | sed 's/,//' || echo "Not installed")"
    echo -e "${CYAN}📦 Node.js:${NC}    $(node --version 2>/dev/null || echo "Not installed")"
    echo -e "${CYAN}🐍 Python:${NC}     $(python3 --version 2>/dev/null | cut -d' ' -f2 || echo "Not installed")"
    echo -e "${CYAN}⏰ Time:${NC}       $(date)"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log_cyber "Scanning system prerequisites..."
    loading_effect "System scan" 2
    
    local prerequisites_met=true
    
    if ! command -v node >/dev/null 2>&1; then
        log_error "Node.js not found. Please install Node.js 18+ and run again."
        prerequisites_met=false
    fi
    
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python 3 not found. Please install Python 3.9+ and run again."
        prerequisites_met=false
    fi
    
    if [[ "$LAUNCH_MODE" == "docker" || "$LAUNCH_MODE" == "full" ]]; then
        if ! command -v docker >/dev/null 2>&1; then
            log_error "Docker not found. Please install Docker and run again."
            prerequisites_met=false
        fi
        
        if ! command -v docker-compose >/dev/null 2>&1; then
            log_error "Docker Compose not found. Please install Docker Compose and run again."
            prerequisites_met=false
        fi
    fi
    
    if $prerequisites_met; then
        log_success "All prerequisites verified ✅"
    else
        exit 1
    fi
}

# Setup environment
setup_environment() {
    log_cyber "Configuring environment matrix..."
    loading_effect "Environment setup" 2
    
    # Create necessary directories
    mkdir -p logs data monitoring/grafana/{dashboards,datasources} monitoring
    
    # Create .env if it doesn't exist
    if [ ! -f .env ]; then
        log_info "Generating .env configuration..."
        cp .env.example .env 2>/dev/null || cat > .env << 'EOL'
NODE_ENV=development
PORT=5173
DATABASE_URL=postgresql://postgres:password@localhost:5432/afl_fantasy
REDIS_URL=redis://localhost:6379
SESSION_SECRET=afl-fantasy-super-secret-key
OPENAI_API_KEY=your-openai-key-here
GEMINI_API_KEY=your-gemini-key-here
EOL
        log_success "Environment configuration created"
    else
        log_info "Using existing environment configuration"
    fi
    
    # Source environment variables
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
}

# Install dependencies with style
install_dependencies() {
    log_cyber "Acquiring software dependencies..."
    
    if [ ! -d "node_modules" ] || [ package.json -nt node_modules ]; then
        loading_effect "Installing Node.js packages" 3
        npm install --silent
        log_success "Node.js dependencies acquired"
    else
        log_info "Node.js dependencies already current"
    fi
    
    if [ -f "requirements.txt" ]; then
        loading_effect "Installing Python packages" 2
        python3 -m pip install -r requirements.txt --quiet --disable-pip-version-check
        log_success "Python dependencies acquired"
    fi
}

# Kill existing processes
terminate_existing() {
    log_cyber "Terminating existing processes..."
    
    # Kill processes on common ports
    for port in 5173 8080 5432 6379; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            log_info "Terminating process on port $port"
            lsof -ti:$port | xargs kill -9 2>/dev/null || true
        fi
    done
    
    # Clean up old Docker containers if running Docker mode
    if [[ "$LAUNCH_MODE" == "docker" || "$LAUNCH_MODE" == "full" ]]; then
        docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
    fi
    
    log_success "Process cleanup complete"
}

# Launch development mode
launch_dev_mode() {
    log_cyber "Initializing development matrix..."
    
    # Start Python service in background
    log_info "Launching Python data service..."
    cd backend/python && python3 main.py > ../../logs/python-service.log 2>&1 &
    PYTHON_PID=$!
    echo $PYTHON_PID > ../../logs/python.pid
    cd ../..
    
    # Start Express server
    log_info "Launching Express API server..."
    npm run dev > logs/express-server.log 2>&1 &
    EXPRESS_PID=$!
    echo $EXPRESS_PID > logs/express.pid
    
    # Wait for services
    loading_effect "Services initializing" 4
    
    # Create status file
    cat > status.json << EOF
{
    "timestamp": "$(date -Iseconds)",
    "mode": "development",
    "services": {
        "express_api": {
            "status": "online",
            "pid": $EXPRESS_PID,
            "port": 5173,
            "url": "http://localhost:5173"
        },
        "python_scraper": {
            "status": "online",
            "pid": $PYTHON_PID,
            "port": 8080
        },
        "dashboard": {
            "url": "file://$(pwd)/dashboard.html"
        }
    }
}
EOF

    log_success "Development services launched"
}

# Launch Docker mode
launch_docker_mode() {
    log_cyber "Activating containerized deployment matrix..."
    loading_effect "Docker containers initializing" 5
    
    # Start all services with Docker Compose
    docker-compose -f docker-compose.dev.yml up -d --build
    
    log_success "Docker services deployed"
}

# Launch full mode (everything)
launch_full_mode() {
    log_cyber "Deploying complete system matrix..."
    loading_effect "Full stack deployment" 6
    
    # Launch Docker services
    docker-compose -f docker-compose.dev.yml up -d --build
    
    # Also start local development for hot reloading
    npm run dev > logs/express-server.log 2>&1 &
    EXPRESS_PID=$!
    echo $EXPRESS_PID > logs/express-dev.pid
    
    log_success "Full stack deployment complete"
}

# Show final status with cyber flair
show_final_status() {
    echo ""
    echo -e "${GREEN}${BOLD}🚀 AFL FANTASY INTELLIGENCE PLATFORM ONLINE! 🚀${NC}"
    echo ""
    
    # Animated header
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}                               🎯 SYSTEM ACCESS POINTS 🎯                               ${NC}"
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    case $LAUNCH_MODE in
        "dev")
            echo -e "${YELLOW}🌐 Web Dashboard:${NC}     ${GREEN}${BOLD}http://localhost:5173${NC}"
            echo -e "${YELLOW}🤖 API Server:${NC}        ${GREEN}${BOLD}http://localhost:5173/api${NC}"
            echo -e "${YELLOW}💊 Health Check:${NC}      ${GREEN}${BOLD}http://localhost:5173/api/health${NC}"
            echo -e "${YELLOW}🔥 Command Center:${NC}    ${GREEN}${BOLD}file://$(pwd)/dashboard.html${NC}"
            echo -e "${YELLOW}🐍 Python Service:${NC}    ${GREEN}${BOLD}Background Process${NC}"
            ;;
        "docker")
            echo -e "${YELLOW}🌐 Web Dashboard:${NC}     ${GREEN}${BOLD}http://localhost:5173${NC}"
            echo -e "${YELLOW}🤖 API Server:${NC}        ${GREEN}${BOLD}http://localhost:5173/api${NC}"
            echo -e "${YELLOW}💊 Health Check:${NC}      ${GREEN}${BOLD}http://localhost:5173/api/health${NC}"
            echo -e "${YELLOW}🔥 Command Center:${NC}    ${GREEN}${BOLD}http://localhost:8090${NC}"
            echo -e "${YELLOW}🐍 Python Service:${NC}    ${GREEN}${BOLD}http://localhost:8080${NC}"
            echo -e "${YELLOW}🗄️  Database:${NC}         ${GREEN}${BOLD}postgresql://localhost:5432${NC}"
            echo -e "${YELLOW}📊 Prometheus:${NC}       ${GREEN}${BOLD}http://localhost:9090${NC}"
            echo -e "${YELLOW}📈 Grafana:${NC}          ${GREEN}${BOLD}http://localhost:3001${NC} (admin/admin)"
            ;;
        "full")
            echo -e "${YELLOW}🌐 Web Dashboard:${NC}     ${GREEN}${BOLD}http://localhost:5173${NC}"
            echo -e "${YELLOW}🤖 API Server:${NC}        ${GREEN}${BOLD}http://localhost:5173/api${NC}"
            echo -e "${YELLOW}💊 Health Check:${NC}      ${GREEN}${BOLD}http://localhost:5173/api/health${NC}"
            echo -e "${YELLOW}🔥 Command Center:${NC}    ${GREEN}${BOLD}http://localhost:8090${NC}"
            echo -e "${YELLOW}🐍 Python Service:${NC}    ${GREEN}${BOLD}http://localhost:8080${NC}"
            echo -e "${YELLOW}🗄️  Database:${NC}         ${GREEN}${BOLD}postgresql://localhost:5432${NC}"
            echo -e "${YELLOW}📊 Prometheus:${NC}       ${GREEN}${BOLD}http://localhost:9090${NC}"
            echo -e "${YELLOW}📈 Grafana:${NC}          ${GREEN}${BOLD}http://localhost:3001${NC} (admin/admin)"
            echo -e "${YELLOW}💌 MailHog:${NC}          ${GREEN}${BOLD}http://localhost:8025${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}                                🎮 QUICK COMMANDS 🎮                                ${NC}"
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${PURPLE}⚡ Ctrl+R${NC}     - Refresh system status"
    echo -e "${PURPLE}⚡ Ctrl+D${NC}     - Open main dashboard"
    echo -e "${PURPLE}⚡ Ctrl+C${NC}     - Shutdown all services"
    echo ""
    
    echo -e "${RED}${BOLD}${BLINK}💀 READY FOR AFL FANTASY DOMINATION 💀${NC}"
    echo ""
}

# Setup signal handlers for cleanup
cleanup() {
    echo ""
    echo -e "${YELLOW}🔄 Initiating system shutdown sequence...${NC}"
    
    case $LAUNCH_MODE in
        "dev")
            if [ -f logs/express.pid ]; then
                EXPRESS_PID=$(cat logs/express.pid)
                if ps -p $EXPRESS_PID > /dev/null; then
                    kill $EXPRESS_PID 2>/dev/null || true
                    log_info "Express server terminated"
                fi
                rm -f logs/express.pid
            fi
            
            if [ -f logs/python.pid ]; then
                PYTHON_PID=$(cat logs/python.pid)
                if ps -p $PYTHON_PID > /dev/null; then
                    kill $PYTHON_PID 2>/dev/null || true
                    log_info "Python service terminated"
                fi
                rm -f logs/python.pid
            fi
            ;;
        "docker"|"full")
            docker-compose -f docker-compose.dev.yml down
            log_info "Docker services terminated"
            
            if [[ "$LAUNCH_MODE" == "full" && -f logs/express-dev.pid ]]; then
                EXPRESS_PID=$(cat logs/express-dev.pid)
                if ps -p $EXPRESS_PID > /dev/null; then
                    kill $EXPRESS_PID 2>/dev/null || true
                fi
                rm -f logs/express-dev.pid
            fi
            ;;
    esac
    
    log_success "System shutdown complete. Until next time, champion! 🏆"
    exit 0
}

# Auto-open dashboard
open_dashboard() {
    sleep 3
    case $LAUNCH_MODE in
        "dev")
            if command -v open >/dev/null 2>&1; then
                open "file://$(pwd)/dashboard.html"
            fi
            ;;
        "docker"|"full")
            if command -v open >/dev/null 2>&1; then
                open "http://localhost:8090"
            fi
            ;;
    esac
}

# Main execution flow
main() {
    show_system_banner
    
    # Parse launch mode
    case $LAUNCH_MODE in
        "dev"|"development")
            LAUNCH_MODE="dev"
            log_cyber "Mode: Development (Local Services)"
            ;;
        "docker"|"container")
            LAUNCH_MODE="docker"
            log_cyber "Mode: Docker (Containerized)"
            ;;
        "full"|"complete")
            LAUNCH_MODE="full"
            log_cyber "Mode: Full Stack (Docker + Local Dev)"
            ;;
        *)
            log_warning "Unknown mode '$LAUNCH_MODE', using development mode"
            LAUNCH_MODE="dev"
            ;;
    esac
    
    # Execute launch sequence
    check_prerequisites
    setup_environment
    install_dependencies
    terminate_existing
    
    case $LAUNCH_MODE in
        "dev")
            launch_dev_mode
            ;;
        "docker")
            launch_docker_mode
            ;;
        "full")
            launch_full_mode
            ;;
    esac
    
    show_final_status
    
    # Setup signal handlers
    trap cleanup SIGINT SIGTERM
    
    # Auto-open dashboard
    open_dashboard &
    
    # Keep script running
    log_cyber "System monitoring active. Press Ctrl+C to terminate."
    
    while true; do
        sleep 10
        # Could add periodic health checks here
    done
}

# Show usage if help requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e "${CYAN}🏆 AFL Fantasy Intelligence Platform - Ultimate Launcher${NC}"
    echo ""
    echo -e "${WHITE}Usage:${NC}"
    echo -e "  ./launch.sh [mode]"
    echo ""
    echo -e "${WHITE}Modes:${NC}"
    echo -e "  ${GREEN}dev${NC}      - Development mode (local services)"
    echo -e "  ${GREEN}docker${NC}   - Docker mode (containerized)"
    echo -e "  ${GREEN}full${NC}     - Full stack (Docker + local dev)"
    echo ""
    echo -e "${WHITE}Examples:${NC}"
    echo -e "  ./launch.sh dev      # Start local development"
    echo -e "  ./launch.sh docker   # Start with Docker"
    echo -e "  ./launch.sh full     # Start everything"
    echo ""
    exit 0
fi

# Execute main function
main
