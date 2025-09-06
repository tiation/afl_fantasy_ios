#!/usr/bin/env bash

# AFL Fantasy Platform - Environment Loader
# Sources .env file and validates required environment variables
# Usage: source scripts/load_env.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[ENV]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[ENV]${NC} ✅ $1"
}

print_warning() {
    echo -e "${YELLOW}[ENV]${NC} ⚠️ $1"
}

print_error() {
    echo -e "${RED}[ENV]${NC} ❌ $1"
}

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

print_info "Loading AFL Fantasy Platform environment..."

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    print_error ".env file not found at: $ENV_FILE"
    
    # Check if .env.example exists
    if [ -f "$PROJECT_ROOT/.env.example" ]; then
        print_info "Found .env.example, creating .env from template..."
        cp "$PROJECT_ROOT/.env.example" "$ENV_FILE"
        print_success "Created .env from .env.example"
        print_warning "Please edit .env with your actual configuration values"
    else
        print_error ".env.example not found either. Please create environment configuration."
        return 1 2>/dev/null || exit 1
    fi
fi

# Source the .env file
print_info "Sourcing environment variables from: $ENV_FILE"
set -a  # Automatically export all variables
source "$ENV_FILE"
set +a  # Stop auto-exporting

# Set default values for missing variables
export NODE_ENV="${NODE_ENV:-development}"
export PORT="${PORT:-5173}"
export API_PORT="${API_PORT:-4000}"
export APP_NAME="${APP_NAME:-AFL Fantasy Intelligence Platform}"
export APP_VERSION="${APP_VERSION:-1.0.0}"

# Database defaults
export DB_HOST="${DB_HOST:-localhost}"
export DB_PORT="${DB_PORT:-5432}"
export DB_NAME="${DB_NAME:-afl_fantasy}"
export DB_USER="${DB_USER:-postgres}"
export DATABASE_URL="${DATABASE_URL:-postgresql://$DB_USER:${DB_PASSWORD:-password}@$DB_HOST:$DB_PORT/$DB_NAME}"

# Redis defaults
export REDIS_HOST="${REDIS_HOST:-localhost}"
export REDIS_PORT="${REDIS_PORT:-6379}"
export REDIS_URL="${REDIS_URL:-redis://$REDIS_HOST:$REDIS_PORT}"

# Python service defaults
export PYTHON_AI_PORT="${PYTHON_AI_PORT:-8080}"
export PYTHON_SCRAPER_PORT="${PYTHON_SCRAPER_PORT:-9001}"
export PYTHON_SERVICE_URL="${PYTHON_SERVICE_URL:-http://localhost:$PYTHON_AI_PORT}"
export PYTHON_SCRAPER_URL="${PYTHON_SCRAPER_URL:-http://localhost:$PYTHON_SCRAPER_PORT}"

# iOS defaults
export IOS_BUNDLE_ID="${IOS_BUNDLE_ID:-com.aflFantasy.app}"
export IOS_API_BASE_URL="${IOS_API_BASE_URL:-http://localhost:$PORT/api}"
export IOS_SIMULATOR_DEVICE="${IOS_SIMULATOR_DEVICE:-iPhone 15}"

# Monitoring defaults
export STATUS_DASHBOARD_PORT="${STATUS_DASHBOARD_PORT:-8090}"
export HEALTH_CHECK_INTERVAL="${HEALTH_CHECK_INTERVAL:-30000}"
export PROMETHEUS_URL="${PROMETHEUS_URL:-http://localhost:9090}"
export GRAFANA_URL="${GRAFANA_URL:-http://localhost:3001}"

# Development defaults
export LOG_LEVEL="${LOG_LEVEL:-info}"
export AUTO_MIGRATE="${AUTO_MIGRATE:-true}"
export SEED_DATABASE="${SEED_DATABASE:-true}"
export CORS_ORIGIN="${CORS_ORIGIN:-http://localhost:$PORT}"

# Feature flags
export ENABLE_AI_PREDICTIONS="${ENABLE_AI_PREDICTIONS:-true}"
export ENABLE_REAL_TIME_UPDATES="${ENABLE_REAL_TIME_UPDATES:-true}"
export ENABLE_PUSH_NOTIFICATIONS="${ENABLE_PUSH_NOTIFICATIONS:-false}"
export ENABLE_ANALYTICS="${ENABLE_ANALYTICS:-true}"

# Workspace integration
export WORKSPACE_PATH="${WORKSPACE_PATH:-$PROJECT_ROOT}"
export DASHBOARD_URL="${DASHBOARD_URL:-http://localhost:$PORT}"
export API_DOCS_URL="${API_DOCS_URL:-http://localhost:$PORT/api/docs}"
export HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-http://localhost:$PORT/api/health}"

print_success "Environment variables loaded successfully"

# Validate required variables for different environments
validate_environment() {
    local errors=0
    
    # Always required
    local required_vars=(
        "NODE_ENV"
        "PORT" 
        "DATABASE_URL"
        "REDIS_URL"
    )
    
    # Production-specific requirements
    if [ "$NODE_ENV" = "production" ]; then
        required_vars+=(
            "SESSION_SECRET"
            "JWT_SECRET"
        )
    fi
    
    # AI features requirements
    if [ "$ENABLE_AI_PREDICTIONS" = "true" ]; then
        if [ -z "${OPENAI_API_KEY:-}" ] && [ -z "${GEMINI_API_KEY:-}" ]; then
            print_warning "AI predictions enabled but no AI API keys configured"
        fi
    fi
    
    # Check required variables
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            print_error "Required environment variable '$var' is not set"
            errors=$((errors + 1))
        fi
    done
    
    # Check for placeholder values that need to be replaced
    local placeholder_vars=(
        "AFL_FANTASY_TEAM_ID:your_team_id_here"
        "AFL_FANTASY_API_TOKEN:your_api_token_here"
        "OPENAI_API_KEY:your_openai_api_key_here"
        "GEMINI_API_KEY:your_gemini_api_key_here"
        "SESSION_SECRET:your-very-long-random-session-secret-here"
        "JWT_SECRET:your-jwt-secret-here"
    )
    
    for var_placeholder in "${placeholder_vars[@]}"; do
        IFS=':' read -r var placeholder <<< "$var_placeholder"
        if [ "${!var:-}" = "$placeholder" ]; then
            print_warning "Variable '$var' still has placeholder value - please configure with real value"
        fi
    done
    
    if [ $errors -gt 0 ]; then
        print_error "Environment validation failed with $errors errors"
        return 1
    else
        print_success "Environment validation passed"
    fi
}

# Run validation unless explicitly disabled
if [ "${SKIP_ENV_VALIDATION:-false}" != "true" ]; then
    validate_environment
fi

# Export useful aliases for development
alias show-env="env | grep -E '^(NODE_ENV|PORT|DATABASE_URL|REDIS_URL|PYTHON_.*_URL|IOS_.*|ENABLE_.*|DASHBOARD_URL)=' | sort"
alias show-urls="echo -e '${GREEN}🔗 Quick Access URLs:${NC}\\n  Dashboard: $DASHBOARD_URL\\n  API Health: $HEALTH_CHECK_URL\\n  API Docs: $API_DOCS_URL\\n  Grafana: $GRAFANA_URL\\n  Prometheus: $PROMETHEUS_URL'"

# Print environment summary
print_info "Environment Configuration Summary:"
echo -e "  • Environment: ${GREEN}$NODE_ENV${NC}"
echo -e "  • Main Port: ${GREEN}$PORT${NC}"
echo -e "  • API Port: ${GREEN}$API_PORT${NC}"
echo -e "  • Database: ${GREEN}$DB_HOST:$DB_PORT/$DB_NAME${NC}"
echo -e "  • Redis: ${GREEN}$REDIS_HOST:$REDIS_PORT${NC}"
echo -e "  • Python AI: ${GREEN}localhost:$PYTHON_AI_PORT${NC}"
echo -e "  • Python Scraper: ${GREEN}localhost:$PYTHON_SCRAPER_PORT${NC}"
echo -e "  • iOS Bundle: ${GREEN}$IOS_BUNDLE_ID${NC}"

# Show feature flags status
echo -e "  • AI Predictions: $([ "$ENABLE_AI_PREDICTIONS" = "true" ] && echo "${GREEN}enabled${NC}" || echo "${YELLOW}disabled${NC}")"
echo -e "  • Real-time Updates: $([ "$ENABLE_REAL_TIME_UPDATES" = "true" ] && echo "${GREEN}enabled${NC}" || echo "${YELLOW}disabled${NC}")"
echo -e "  • Push Notifications: $([ "$ENABLE_PUSH_NOTIFICATIONS" = "true" ] && echo "${GREEN}enabled${NC}" || echo "${YELLOW}disabled${NC}")"

echo ""
print_info "Use 'show-urls' to display quick access URLs"
print_info "Use 'show-env' to display all environment variables"

# Hook into 1Password if configured
if command -v op &> /dev/null && [ -n "${OP_VAULT:-}" ]; then
    print_info "1Password CLI detected - secrets can be sourced from vault: $OP_VAULT"
    
    # Function to get secret from 1Password
    get_secret() {
        local item="$1"
        local field="${2:-password}"
        op item get "$item" --vault="$OP_VAULT" --field="$field" 2>/dev/null || echo ""
    }
    
    # Function to inject 1Password secrets
    inject_op_secrets() {
        print_info "Injecting secrets from 1Password vault: $OP_VAULT"
        
        # Example secret injections (uncomment and modify as needed)
        # export OPENAI_API_KEY="$(get_secret 'OpenAI-API' 'credential')"
        # export GEMINI_API_KEY="$(get_secret 'Gemini-API' 'credential')"
        # export AFL_FANTASY_API_TOKEN="$(get_secret 'AFL-Fantasy-API' 'credential')"
        # export DATABASE_PASSWORD="$(get_secret 'PostgreSQL' 'password')"
        
        print_success "1Password secrets injection complete"
    }
    
    # Make function available
    export -f inject_op_secrets get_secret
fi

# Warp terminal integration
if [ -n "${WARP_TERMINAL:-}" ]; then
    print_info "Warp terminal detected - setting up workflows"
    
    # Export Warp-specific environment
    export WARP_THEME="${WARP_THEME:-dark}"
    export WARP_AI_ENABLED="${WARP_AI_ENABLED:-true}"
    
    # Add project-specific Warp workflows
    if [ -f "$PROJECT_ROOT/.warp/workflows.yml" ]; then
        print_success "Warp workflows configuration found"
    fi
fi

print_success "Environment setup complete! 🚀"
