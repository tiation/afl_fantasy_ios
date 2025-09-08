#!/bin/bash
set -eo pipefail

# Colors and formatting
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
EXPRESS_PORT=${EXPRESS_PORT:-5002}
HEALTH_PORT=${HEALTH_PORT:-5005}
DASHBOARD_PORT=${DASHBOARD_PORT:-3000}
MONITOR_INTERVAL=5
MAX_RETRIES=3
HEALTH_CHECK_TIMEOUT=10

# Directories
LOG_DIR="/tmp/afl_fantasy_logs"
PID_DIR="/tmp/afl_fantasy_pids"
CONFIG_DIR="config"

# Initialize directories
mkdir -p "$LOG_DIR" "$PID_DIR" "$CONFIG_DIR"

# Service definitions
declare -A SERVICES=(
    ["express"]="$EXPRESS_PORT:server/index.ts:tsx"
    ["health"]="$HEALTH_PORT:api/health.py:python"
    ["dashboard"]="$DASHBOARD_PORT:dashboards:serve"
)

# Logging functions
log_info() { echo -e "${BLUE}[INFO $(date '+%H:%M:%S')]${NC} $*" | tee -a "$LOG_DIR/startup.log"; }
log_warn() { echo -e "${YELLOW}[WARN $(date '+%H:%M:%S')]${NC} $*" | tee -a "$LOG_DIR/startup.log"; }
log_error() { echo -e "${RED}[ERROR $(date '+%H:%M:%S')]${NC} $*" | tee -a "$LOG_DIR/startup.log"; }
log_success() { echo -e "${GREEN}[SUCCESS $(date '+%H:%M:%S')]${NC} $*" | tee -a "$LOG_DIR/startup.log"; }

# Port management
check_port() {
    local port=$1
    lsof -i :"$port" >/dev/null 2>&1
}

kill_port() {
    local port=$1
    local pids
    pids=$(lsof -ti :"$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        log_warn "Killing processes on port $port: $pids"
        echo "$pids" | xargs -r kill -9 2>/dev/null || true
        sleep 1
    fi
}

# Service management
start_service() {
    local service=$1
    local config=${SERVICES[$service]}
    local port=$(echo "$config" | cut -d: -f1)
    local script=$(echo "$config" | cut -d: -f2)
    local runner=$(echo "$config" | cut -d: -f3)
    
    log_info "Starting $service on port $port"
    
    # Kill existing process on port
    kill_port "$port"
    
    # Set environment variables
    export PORT="$port"
    export NODE_ENV=development
    export PYTHONPATH="$PWD"
    
    # Start service based on runner type
    case $runner in
        "tsx")
            if [ ! -d "$(dirname "$script")" ]; then
                log_error "Directory $(dirname "$script") does not exist"
                return 1
            fi
            cd "$(dirname "$script")"
            if ! command -v tsx >/dev/null; then
                log_error "tsx not found. Installing..."
                npm install -g tsx || return 1
            fi
            tsx "$(basename "$script")" > "$LOG_DIR/${service}.log" 2>&1 &
            echo $! > "$PID_DIR/${service}.pid"
            cd - >/dev/null
            ;;
        "python")
            if [ ! -f "$script" ]; then
                log_error "Python script $script does not exist"
                return 1
            fi
            python3 "$script" > "$LOG_DIR/${service}.log" 2>&1 &
            echo $! > "$PID_DIR/${service}.pid"
            ;;
        "serve")
            if [ ! -d "$script" ]; then
                log_error "Directory $script does not exist"
                return 1
            fi
            cd "$script"
            python3 -m http.server "$port" > "$LOG_DIR/${service}.log" 2>&1 &
            echo $! > "$PID_DIR/${service}.pid"
            cd - >/dev/null
            ;;
    esac
    
    # Wait for service to start
    local retries=0
    while [ $retries -lt $MAX_RETRIES ]; do
        sleep 2
        if health_check "$service" "$port"; then
            log_success "$service started successfully on port $port"
            return 0
        fi
        retries=$((retries + 1))
        log_warn "$service startup attempt $retries/$MAX_RETRIES failed, retrying..."
    done
    
    log_error "Failed to start $service after $MAX_RETRIES attempts"
    show_service_logs "$service" 10
    return 1
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
                log_warn "Force killing $service"
                kill -9 "$pid" 2>/dev/null || true
            fi
        fi
        rm -f "$pid_file"
    fi
    
    # Also kill by port
    local config=${SERVICES[$service]}
    local port=$(echo "$config" | cut -d: -f1)
    kill_port "$port"
}

health_check() {
    local service=$1
    local port=$2
    
    case $service in
        "express"|"health")
            timeout $HEALTH_CHECK_TIMEOUT curl -s "http://localhost:$port/health" >/dev/null 2>&1
            ;;
        "dashboard")
            timeout $HEALTH_CHECK_TIMEOUT curl -s "http://localhost:$port" >/dev/null 2>&1
            ;;
        *)
            check_port "$port"
            ;;
    esac
}

# Logging and status
show_service_logs() {
    local service=$1
    local lines=${2:-20}
    
    echo -e "\n${CYAN}=== $service logs (last $lines lines) ===${NC}"
    if [ -f "$LOG_DIR/${service}.log" ]; then
        tail -n "$lines" "$LOG_DIR/${service}.log" | sed "s/^/${MAGENTA}[$service]${NC} /"
    else
        echo "No logs found for $service"
    fi
}

show_all_logs() {
    local lines=${1:-10}
    for service in "${!SERVICES[@]}"; do
        show_service_logs "$service" "$lines"
        echo
    done
}

show_status() {
    echo -e "\n${BOLD}${BLUE}AFL Fantasy Platform Status${NC}"
    echo -e "${BLUE}==============================${NC}\n"
    
    local all_healthy=true
    
    for service in "${!SERVICES[@]}"; do
        local config=${SERVICES[$service]}
        local port=$(echo "$config" | cut -d: -f1)
        local pid_file="$PID_DIR/${service}.pid"
        local status_icon=""
        local status_text=""
        local pid=""
        
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
        fi
        
        if health_check "$service" "$port"; then
            status_icon="${GREEN}✓${NC}"
            status_text="${GREEN}Running${NC}"
        else
            status_icon="${RED}✗${NC}"
            status_text="${RED}Stopped${NC}"
            all_healthy=false
        fi
        
        printf "%-12s %s %-10s Port: %-6s PID: %-8s\n" "$service" "$status_icon" "$status_text" "$port" "${pid:-N/A}"
    done
    
    echo
    if $all_healthy; then
        echo -e "${GREEN}${BOLD}Overall Status: All services healthy${NC}"
    else
        echo -e "${RED}${BOLD}Overall Status: Some services need attention${NC}"
    fi
    
    # Show URLs
    echo -e "\n${BLUE}Service URLs:${NC}"
    for service in "${!SERVICES[@]}"; do
        local port=$(echo "${SERVICES[$service]}" | cut -d: -f1)
        if health_check "$service" "$port"; then
            case $service in
                "express")
                    echo -e "  ${GREEN}Express API:${NC} http://localhost:$port"
                    ;;
                "health")
                    echo -e "  ${GREEN}Health Monitor:${NC} http://localhost:$port/health"
                    ;;
                "dashboard")
                    echo -e "  ${GREEN}Dashboard:${NC} http://localhost:$port"
                    ;;
            esac
        fi
    done
}

# Prerequisites check
check_prerequisites() {
    log_info "Checking prerequisites"
    
    # Check Node.js
    if ! command -v node >/dev/null; then
        log_error "Node.js is required but not installed"
        return 1
    fi
    log_success "Node.js $(node -v) found"
    
    # Check Python
    if ! command -v python3 >/dev/null; then
        log_error "Python 3 is required but not installed"
        return 1
    fi
    log_success "Python $(python3 --version) found"
    
    return 0
}

# Main functions
start_all() {
    log_info "Starting AFL Fantasy Platform"
    
    # Check prerequisites
    check_prerequisites || exit 1
    
    for service in "${!SERVICES[@]}"; do
        start_service "$service" || {
            log_error "Failed to start $service, stopping all services"
            stop_all
            exit 1
        }
    done
    
    log_success "All services started successfully"
    show_status
}

stop_all() {
    log_info "Stopping all services"
    
    for service in "${!SERVICES[@]}"; do
        stop_service "$service"
    done
    
    # Kill any remaining processes
    pkill -f 'node|tsx|python' 2>/dev/null || true
    
    log_success "All services stopped"
}

restart_all() {
    log_info "Restarting all services"
    stop_all
    sleep 3
    start_all
}

# Interactive mode
interactive_mode() {
    while true; do
        echo -e "\n${BOLD}AFL Fantasy Platform Control${NC}"
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
            5) show_all_logs ;;
            6) exit 0 ;;
            *) log_warn "Invalid option" ;;
        esac
    done
}

# Change to project root directory
cd "$(dirname "$0")/.."

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
        show_all_logs "${2:-20}"
        ;;
    "interactive")
        interactive_mode
        ;;
    "health")
        show_status
        ;;
    *)
        echo -e "${BOLD}AFL Fantasy Platform Manager${NC}"
        echo "Usage: $0 {start|stop|restart|status|logs|interactive|health}"
        echo ""
        echo "Commands:"
        echo "  start       - Start all services"
        echo "  stop        - Stop all services"
        echo "  restart     - Restart all services"
        echo "  status      - Show service status"
        echo "  logs [N]    - Show last N lines of logs (default: 20)"
        echo "  interactive - Enter interactive mode"
        echo "  health      - Quick health check"
        ;;
esac
