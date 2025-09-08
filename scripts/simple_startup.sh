#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
EXPRESS_PORT=5002
HEALTH_PORT=5005
DASHBOARD_PORT=3000

# Directories
LOG_DIR="/tmp/afl_fantasy_logs"
PID_DIR="/tmp/afl_fantasy_pids"

# Create directories
mkdir -p "$LOG_DIR" "$PID_DIR"

# Logging functions
log_info() { echo -e "${BLUE}[INFO $(date '+%H:%M:%S')]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN $(date '+%H:%M:%S')]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR $(date '+%H:%M:%S')]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS $(date '+%H:%M:%S')]${NC} $*"; }

# Port management
check_port() {
    lsof -i :"$1" >/dev/null 2>&1
}

kill_port() {
    local port=$1
    local pids=$(lsof -ti :"$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        log_warn "Killing processes on port $port"
        echo "$pids" | xargs kill -9 2>/dev/null || true
        sleep 1
    fi
}

# Service management
start_express() {
    log_info "Starting Express server on port $EXPRESS_PORT"
    kill_port "$EXPRESS_PORT"
    
    if [ ! -d "server" ]; then
        log_error "Server directory not found"
        return 1
    fi
    
    # Set a default DATABASE_URL if not provided
    export DATABASE_URL=${DATABASE_URL:-"postgresql://localhost:5432/afl_fantasy"}
    export NODE_ENV=development
    export PORT="$EXPRESS_PORT"
    
    cd server
    if ! command -v tsx >/dev/null; then
        log_error "tsx is required. Installing..."
        npm install -g tsx || return 1
    fi
    
    tsx index.ts > "$LOG_DIR/express.log" 2>&1 &
    echo $! > "$PID_DIR/express.pid"
    cd ..
    
    # Wait and check
    sleep 5
    if check_port "$EXPRESS_PORT"; then
        log_success "Express server started"
        return 0
    else
        log_error "Express server failed to start"
        log_warn "Checking logs..."
        tail -10 "$LOG_DIR/express.log"
        return 1
    fi
}

start_health() {
    log_info "Starting Health Monitor on port $HEALTH_PORT"
    kill_port "$HEALTH_PORT"
    
    if [ ! -f "api/health.py" ]; then
        log_error "Health API script not found"
        return 1
    fi
    
    export PORT="$HEALTH_PORT"
    python3 api/health.py > "$LOG_DIR/health.log" 2>&1 &
    echo $! > "$PID_DIR/health.pid"
    
    # Wait and check
    sleep 3
    if check_port "$HEALTH_PORT"; then
        log_success "Health Monitor started"
        return 0
    else
        log_error "Health Monitor failed to start"
        return 1
    fi
}

start_dashboard() {
    log_info "Starting Dashboard on port $DASHBOARD_PORT"
    kill_port "$DASHBOARD_PORT"
    
    if [ ! -d "dashboards" ]; then
        log_error "Dashboard directory not found"
        return 1
    fi
    
    cd dashboards
    python3 -m http.server "$DASHBOARD_PORT" > "$LOG_DIR/dashboard.log" 2>&1 &
    echo $! > "$PID_DIR/dashboard.pid"
    cd ..
    
    # Wait and check
    sleep 2
    if check_port "$DASHBOARD_PORT"; then
        log_success "Dashboard started"
        return 0
    else
        log_error "Dashboard failed to start"
        return 1
    fi
}

stop_service() {
    local service=$1
    local pid_file="$PID_DIR/${service}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Stopping $service (PID: $pid)"
            kill -TERM "$pid" 2>/dev/null || true
            sleep 2
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null || true
            fi
        fi
        rm -f "$pid_file"
    fi
}

show_status() {
    echo -e "\n${BLUE}AFL Fantasy Platform Status${NC}"
    echo -e "${BLUE}==============================${NC}"
    
    # Express status
    if check_port "$EXPRESS_PORT"; then
        echo -e "Express Server:  ${GREEN}✓ Running${NC} (Port: $EXPRESS_PORT)"
        echo -e "                 ${GREEN}http://localhost:$EXPRESS_PORT${NC}"
    else
        echo -e "Express Server:  ${RED}✗ Stopped${NC} (Port: $EXPRESS_PORT)"
    fi
    
    # Health status
    if check_port "$HEALTH_PORT"; then
        echo -e "Health Monitor:  ${GREEN}✓ Running${NC} (Port: $HEALTH_PORT)"
        echo -e "                 ${GREEN}http://localhost:$HEALTH_PORT/health${NC}"
    else
        echo -e "Health Monitor:  ${RED}✗ Stopped${NC} (Port: $HEALTH_PORT)"
    fi
    
    # Dashboard status
    if check_port "$DASHBOARD_PORT"; then
        echo -e "Dashboard:       ${GREEN}✓ Running${NC} (Port: $DASHBOARD_PORT)"
        echo -e "                 ${GREEN}http://localhost:$DASHBOARD_PORT${NC}"
    else
        echo -e "Dashboard:       ${RED}✗ Stopped${NC} (Port: $DASHBOARD_PORT)"
    fi
    
    echo
}

show_logs() {
    local lines=${1:-20}
    echo -e "\n${BLUE}Recent Logs (last $lines lines):${NC}\n"
    
    for service in express health dashboard; do
        if [ -f "$LOG_DIR/${service}.log" ]; then
            echo -e "${YELLOW}=== $service logs ===${NC}"
            tail -n "$lines" "$LOG_DIR/${service}.log"
            echo
        fi
    done
}

check_prerequisites() {
    log_info "Checking prerequisites"
    
    if ! command -v node >/dev/null; then
        log_error "Node.js is required but not installed"
        return 1
    fi
    log_success "Node.js $(node -v) found"
    
    if ! command -v python3 >/dev/null; then
        log_error "Python 3 is required but not installed"
        return 1
    fi
    log_success "Python $(python3 --version) found"
    
    return 0
}

start_all() {
    log_info "Starting AFL Fantasy Platform"
    
    check_prerequisites || exit 1
    
    # Change to project root
    cd "$(dirname "$0")/.."
    
    start_express || exit 1
    start_health || exit 1
    start_dashboard || exit 1
    
    log_success "All services started successfully"
    show_status
}

stop_all() {
    log_info "Stopping all services"
    
    stop_service express
    stop_service health  
    stop_service dashboard
    
    # Kill any remaining processes
    pkill -f 'node|tsx|python.*http.server' 2>/dev/null || true
    
    log_success "All services stopped"
}

restart_all() {
    stop_all
    sleep 2
    start_all
}

# Interactive mode
interactive_mode() {
    while true; do
        echo -e "\n${BLUE}AFL Fantasy Platform Control${NC}"
        echo "1. Start all services"
        echo "2. Stop all services"
        echo "3. Restart all services"
        echo "4. Show status"
        echo "5. Show logs"
        echo "6. Exit"
        
        read -p "Select option (1-6): " choice
        
        case $choice in
            1) start_all ;;
            2) stop_all ;;
            3) restart_all ;;
            4) show_status ;;
            5) show_logs ;;
            6) exit 0 ;;
            *) log_warn "Invalid option" ;;
        esac
    done
}

# Main execution
case "${1:-}" in
    "start")
        start_all
        ;;
    "stop")
        stop_all
        ;;
    "restart")
        restart_all
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "${2:-20}"
        ;;
    "interactive")
        interactive_mode
        ;;
    *)
        echo -e "${BLUE}AFL Fantasy Platform Manager${NC}"
        echo "Usage: $0 {start|stop|restart|status|logs|interactive}"
        echo ""
        echo "Commands:"
        echo "  start       - Start all services"
        echo "  stop        - Stop all services"
        echo "  restart     - Restart all services"
        echo "  status      - Show service status"
        echo "  logs [N]    - Show last N lines of logs"
        echo "  interactive - Enter interactive mode"
        ;;
esac
