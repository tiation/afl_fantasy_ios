#!/usr/bin/env bash

# AFL Fantasy Platform - Master Setup Script
# Orchestrates the complete platform startup with Docker Compose
# Usage: ./setup.sh [--dev|--clean|--logs|--stop|--status]

set -euo pipefail

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.unified.yml"
ENV_FILE="$PROJECT_ROOT/.env"
LOGS_DIR="$PROJECT_ROOT/logs"

# Default settings
MODE="production"
PROFILES="default,monitoring"
PULL_IMAGES=true
RUN_MIGRATIONS=true
SEED_DATA=true
SHOW_LOGS=false
DETACH_MODE=true

# Functions for output
print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "════════════════════════════════════════════════════════════════"
    echo "  🏆 AFL Fantasy Intelligence Platform Setup"
    echo "════════════════════════════════════════════════════════════════"
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
AFL Fantasy Platform Setup Script

USAGE:
    ./setup.sh [OPTIONS]

OPTIONS:
    --dev           Development mode (includes hot-reload, debug tools)
    --production    Production mode (optimized, stable)
    --clean         Clean start (remove containers, volumes, rebuild)
    --logs          Show logs after startup
    --stop          Stop all services
    --status        Show service status
    --profiles      Comma-separated profiles (default: default,monitoring)
    --no-pull       Skip pulling latest images
    --no-migrate    Skip database migrations
    --no-seed       Skip data seeding
    --help, -h      Show this help message

PROFILES:
    default         Core services (backend, frontend, database)
    monitoring      Prometheus, Grafana, status dashboard
    logging         Loki, Promtail for log aggregation
    python          Python AI and scraper services
    ios             iOS development helpers
    all             All services

EXAMPLES:
    ./setup.sh --dev                    # Development with hot-reload
    ./setup.sh --clean --profiles all   # Full clean rebuild
    ./setup.sh --stop                   # Stop all services
    ./setup.sh --logs --profiles dev    # Start dev services and tail logs

QUICK ACCESS URLs (after startup):
    Frontend:        http://localhost:5173
    Backend API:     http://localhost:4000/api
    Status Dashboard: http://localhost:8090  
    Grafana:         http://localhost:3001
    Prometheus:      http://localhost:9090

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dev)
            MODE="development"
            PROFILES="dev,monitoring"
            DETACH_MODE=false
            shift
            ;;
        --production)
            MODE="production"
            PROFILES="default,monitoring"
            shift
            ;;
        --clean)
            CLEAN_START=true
            shift
            ;;
        --logs)
            SHOW_LOGS=true
            DETACH_MODE=false
            shift
            ;;
        --stop)
            STOP_SERVICES=true
            shift
            ;;
        --status)
            SHOW_STATUS=true
            shift
            ;;
        --profiles)
            PROFILES="$2"
            shift 2
            ;;
        --no-pull)
            PULL_IMAGES=false
            shift
            ;;
        --no-migrate)
            RUN_MIGRATIONS=false
            shift
            ;;
        --no-seed)
            SEED_DATA=false
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

# Load environment
load_environment() {
    print_section "Loading Environment Configuration"
    
    # Source the environment loader
    if [ -f "$PROJECT_ROOT/scripts/load_env.sh" ]; then
        print_step "Loading environment variables..."
        source "$PROJECT_ROOT/scripts/load_env.sh"
        print_success "Environment loaded successfully"
    else
        print_warning "Environment loader not found, using basic setup"
        
        # Basic environment setup
        if [ ! -f "$ENV_FILE" ]; then
            if [ -f "$PROJECT_ROOT/.env.example" ]; then
                cp "$PROJECT_ROOT/.env.example" "$ENV_FILE"
                print_success "Created .env from example"
            else
                print_error "No environment configuration found"
                exit 1
            fi
        fi
    fi
    
    # Export mode-specific overrides
    export NODE_ENV="$MODE"
    if [ "$MODE" = "development" ]; then
        export PORT="5173"
        export API_PORT="4000"
        export LOG_LEVEL="debug"
    else
        export PORT="5000"
        export API_PORT="5000"
        export LOG_LEVEL="info"
    fi
    
    print_info "Mode: $MODE | Profiles: $PROFILES"
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    local errors=0
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found. Please install Docker Desktop"
        errors=$((errors + 1))
    else
        print_success "Docker $(docker --version | cut -d' ' -f3 | tr -d ',') ✓"
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose not found. Please install Docker Compose"
        errors=$((errors + 1))
    else
        print_success "Docker Compose $(docker compose version --short) ✓"
    fi
    
    # Check compose file
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "Docker compose file not found: $COMPOSE_FILE"
        errors=$((errors + 1))
    else
        print_success "Compose configuration found ✓"
    fi
    
    # Validate compose file
    if ! docker compose -f "$COMPOSE_FILE" config &> /dev/null; then
        print_error "Docker compose configuration is invalid"
        print_info "Run: docker compose -f $COMPOSE_FILE config"
        errors=$((errors + 1))
    else
        print_success "Compose configuration is valid ✓"
    fi
    
    # Check available disk space (at least 2GB)
    local available_space=$(df . | tail -1 | awk '{print $4}')
    local required_space=2097152  # 2GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        print_warning "Low disk space: $(( available_space / 1024 / 1024 ))GB available, 2GB+ recommended"
    else
        print_success "Sufficient disk space available ✓"
    fi
    
    # Create required directories
    mkdir -p "$LOGS_DIR" data backups
    print_success "Required directories created ✓"
    
    if [ $errors -gt 0 ]; then
        print_error "Prerequisites check failed with $errors errors"
        exit 1
    fi
}

# Stop services function
stop_services() {
    print_section "Stopping AFL Fantasy Platform"
    
    print_step "Stopping all services..."
    docker compose -f "$COMPOSE_FILE" down --remove-orphans
    
    print_step "Stopping any remaining containers..."
    docker ps -q --filter "name=afl-fantasy" | xargs -r docker stop
    
    print_success "All services stopped"
}

# Clean function
clean_environment() {
    print_section "Cleaning Environment"
    
    print_step "Stopping all services..."
    docker compose -f "$COMPOSE_FILE" down --remove-orphans --volumes
    
    print_step "Removing containers and images..."
    docker system prune -f --filter "label=com.docker.compose.project=afl-fantasy-platform"
    
    print_step "Cleaning logs..."
    rm -rf "$LOGS_DIR"/*
    
    print_success "Environment cleaned"
}

# Show status function
show_status() {
    print_section "AFL Fantasy Platform Status"
    
    echo -e "${BOLD}Running Containers:${NC}"
    docker compose -f "$COMPOSE_FILE" ps
    
    echo -e "\n${BOLD}Service Health:${NC}"
    
    # Check core services
    local services=("postgres:5432" "redis:6379" "backend:4000" "frontend:5173")
    
    for service in "${services[@]}"; do
        IFS=':' read -r name port <<< "$service"
        if curl -sf "http://localhost:$port" > /dev/null 2>&1 || 
           curl -sf "http://localhost:$port/health" > /dev/null 2>&1 || 
           curl -sf "http://localhost:$port/api/health" > /dev/null 2>&1; then
            echo -e "  ${GREEN}●${NC} $name (port $port) - ${GREEN}healthy${NC}"
        else
            echo -e "  ${RED}●${NC} $name (port $port) - ${RED}unhealthy${NC}"
        fi
    done
    
    echo -e "\n${BOLD}Quick Access:${NC}"
    echo -e "  🌐 Frontend:        ${CYAN}http://localhost:${PORT:-5173}${NC}"
    echo -e "  🔧 API Health:      ${CYAN}http://localhost:${API_PORT:-4000}/api/health${NC}"
    echo -e "  📊 Status Dashboard: ${CYAN}http://localhost:8090${NC}"
    echo -e "  📈 Grafana:         ${CYAN}http://localhost:3001${NC}"
    echo -e "  🔍 Prometheus:      ${CYAN}http://localhost:9090${NC}"
}

# Wait for service function
wait_for_service() {
    local service_name="$1"
    local health_check="$2"
    local timeout="${3:-60}"
    local interval="${4:-5}"
    
    print_step "Waiting for $service_name to be ready..."
    
    local count=0
    local max_attempts=$(( timeout / interval ))
    
    while [ $count -lt $max_attempts ]; do
        if eval "$health_check" &> /dev/null; then
            print_success "$service_name is ready"
            return 0
        fi
        
        count=$((count + 1))
        print_step "Waiting for $service_name... ($count/$max_attempts)"
        sleep $interval
    done
    
    print_error "$service_name failed to become ready within ${timeout}s"
    return 1
}

# Database operations
setup_database() {
    print_section "Setting up Database"
    
    # Wait for PostgreSQL to be ready
    wait_for_service "PostgreSQL" "pg_isready -h localhost -p ${DB_PORT:-5432} -U ${DB_USER:-postgres}" 60
    
    # Wait for Redis to be ready
    wait_for_service "Redis" "redis-cli -h localhost -p ${REDIS_PORT:-6379} ping | grep PONG" 30
    
    if [ "$RUN_MIGRATIONS" = "true" ]; then
        print_step "Running database migrations..."
        
        # Try different migration approaches
        if [ -f "$PROJECT_ROOT/package.json" ] && command -v npm &> /dev/null; then
            if npm run migrate &> /dev/null; then
                print_success "Database migrations completed via npm"
            elif npm run db:migrate &> /dev/null; then
                print_success "Database migrations completed via npm db:migrate"
            else
                print_warning "No npm migration script found, skipping..."
            fi
        fi
        
        # Try Drizzle migrations
        if [ -f "$PROJECT_ROOT/drizzle.config.ts" ] && command -v npx &> /dev/null; then
            if npx drizzle-kit migrate &> /dev/null; then
                print_success "Drizzle migrations completed"
            fi
        fi
    fi
    
    if [ "$SEED_DATA" = "true" ]; then
        print_step "Seeding initial data..."
        
        # Try different seeding approaches
        if [ -f "$PROJECT_ROOT/scripts/seed.js" ]; then
            node "$PROJECT_ROOT/scripts/seed.js" &> /dev/null && print_success "Data seeded via script"
        elif [ -f "$PROJECT_ROOT/backend/python/main.py" ]; then
            # Try Python seeding
            if docker compose -f "$COMPOSE_FILE" exec -T python_scraper python main.py --seed &> /dev/null; then
                print_success "Data seeded via Python scraper"
            fi
        else
            print_warning "No seeding script found, skipping..."
        fi
    fi
}

# Main startup function
startup_services() {
    print_section "Starting AFL Fantasy Platform Services"
    
    # Pull latest images if requested
    if [ "$PULL_IMAGES" = "true" ]; then
        print_step "Pulling latest container images..."
        docker compose -f "$COMPOSE_FILE" pull --quiet
        print_success "Container images updated"
    fi
    
    # Build any local images
    print_step "Building application containers..."
    docker compose -f "$COMPOSE_FILE" build --quiet
    print_success "Application containers built"
    
    # Start services based on profiles
    local profile_args=()
    local up_args=()
    
    IFS=',' read -ra PROFILE_ARRAY <<< "$PROFILES"
    for profile in "${PROFILE_ARRAY[@]}"; do
        profile_args+=("--profile" "$profile")
    done
    
    if [ "$DETACH_MODE" = "true" ]; then
        up_args+=("--detach")
    fi
    
    print_step "Starting services with profiles: $PROFILES"
    
    # Handle empty up_args array to avoid unbound variable error
    if [ ${#up_args[@]} -eq 0 ]; then
        docker compose -f "$COMPOSE_FILE" "${profile_args[@]}" up
    else
        docker compose -f "$COMPOSE_FILE" "${profile_args[@]}" up "${up_args[@]}"
    fi
    
    if [ "$DETACH_MODE" = "true" ]; then
        print_success "Services started in background"
    else
        print_success "Services started"
    fi
}

# Show logs function
show_logs() {
    print_section "Showing Service Logs"
    
    # Show logs for services matching profiles
    local services=()
    if [[ "$PROFILES" == *"dev"* ]] || [[ "$PROFILES" == *"default"* ]]; then
        services+=("backend" "frontend" "postgres" "redis")
    fi
    if [[ "$PROFILES" == *"python"* ]]; then
        services+=("python_ai" "python_scraper")
    fi
    if [[ "$PROFILES" == *"monitoring"* ]]; then
        services+=("prometheus" "grafana")
    fi
    
    if [ ${#services[@]} -eq 0 ]; then
        # Show all logs if no specific services
        docker compose -f "$COMPOSE_FILE" logs -f
    else
        docker compose -f "$COMPOSE_FILE" logs -f "${services[@]}"
    fi
}

# Cleanup trap
cleanup() {
    print_info "Received interrupt signal, cleaning up..."
    # Only stop if we started in non-detached mode
    if [ "${DETACH_MODE:-true}" = "false" ]; then
        docker compose -f "$COMPOSE_FILE" down
    fi
    exit 0
}
trap cleanup INT TERM

# Main execution flow
main() {
    print_header
    
    # Handle special operations first
    if [ "${STOP_SERVICES:-false}" = "true" ]; then
        stop_services
        exit 0
    fi
    
    if [ "${SHOW_STATUS:-false}" = "true" ]; then
        show_status
        exit 0
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Load environment
    load_environment
    
    # Handle clean start
    if [ "${CLEAN_START:-false}" = "true" ]; then
        clean_environment
    fi
    
    # Start services
    startup_services
    
    # Setup database (only if services are running in detached mode)
    if [ "$DETACH_MODE" = "true" ]; then
        setup_database
    fi
    
    # Show final status and URLs
    if [ "$DETACH_MODE" = "true" ]; then
        echo ""
        print_section "🎉 AFL Fantasy Platform Started Successfully!"
        
        echo -e "${BOLD}${GREEN}Quick Access URLs:${NC}"
        echo -e "  🌐 Frontend Dashboard:  ${CYAN}http://localhost:${PORT:-5173}${NC}"
        echo -e "  🔧 API Health Check:    ${CYAN}http://localhost:${API_PORT:-4000}/api/health${NC}"
        echo -e "  📊 Status Dashboard:    ${CYAN}http://localhost:8090${NC}"
        echo -e "  📈 Grafana (admin/admin): ${CYAN}http://localhost:3001${NC}"
        echo -e "  🔍 Prometheus:          ${CYAN}http://localhost:9090${NC}"
        
        echo -e "\n${BOLD}${YELLOW}Management Commands:${NC}"
        echo -e "  ./setup.sh --status     # Show service status"
        echo -e "  ./setup.sh --logs       # View service logs"
        echo -e "  ./setup.sh --stop       # Stop all services"
        echo -e "  docker compose -f $COMPOSE_FILE logs -f [service]  # Tail specific service logs"
        
        echo -e "\n${BOLD}${PURPLE}iOS Development:${NC}"
        echo -e "  ./run_ios.sh            # Start iOS simulator and app"
        echo -e "  open ios/AFLFantasy.xcodeproj  # Open in Xcode"
        
        echo -e "\n${PURPLE}ℹ️  Services are running in background. Check status with --status flag${NC}"
    fi
    
    # Show logs if requested
    if [ "$SHOW_LOGS" = "true" ]; then
        show_logs
    fi
}

# Run main function
main "$@"
