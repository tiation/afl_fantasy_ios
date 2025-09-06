#!/usr/bin/env bash
set -euo pipefail

# AFL Fantasy iOS Backend - Development Setup Script
# This script sets up the development environment for both Python and Node.js services

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log() { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$*"; }

# Check if command exists
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check Python
    if ! command_exists python3; then
        missing_deps+=("python3")
    else
        local python_version=$(python3 --version | cut -d ' ' -f 2)
        local major=$(echo "$python_version" | cut -d '.' -f 1)
        local minor=$(echo "$python_version" | cut -d '.' -f 2)
        if [ "$major" -lt 3 ] || ([ "$major" -eq 3 ] && [ "$minor" -lt 11 ]); then
            error "Python 3.11 or higher required. Found: $python_version"
            exit 1
        fi
        success "Python $python_version found"
    fi
    
    # Check Node.js
    if ! command_exists node; then
        missing_deps+=("node")
    else
        local node_version=$(node --version | sed 's/v//')
        local major=$(echo "$node_version" | cut -d '.' -f 1)
        if [ "$major" -lt 20 ]; then
            error "Node.js 20 or higher required. Found: $node_version"
            exit 1
        fi
        success "Node.js $node_version found"
    fi
    
    # Check pnpm
    if ! command_exists pnpm; then
        warn "pnpm not found, installing..."
        npm install -g pnpm
    else
        success "pnpm found"
    fi
    
    # Check PostgreSQL (optional)
    if command_exists psql; then
        success "PostgreSQL found"
    else
        warn "PostgreSQL not found - you'll need it for production"
        warn "On macOS: brew install postgresql"
        warn "On Ubuntu: sudo apt-get install postgresql postgresql-contrib"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Setup environment variables
setup_environment() {
    log "Setting up environment variables..."
    
    if [ ! -f "Shared/.env" ]; then
        if [ -f "Shared/.env.example" ]; then
            cp "Shared/.env.example" "Shared/.env"
            log "Created .env from .env.example"
        else
            log "Creating new .env file..."
            cat > "Shared/.env" << 'EOF'
# Development Environment Configuration

# Database Configuration
DATABASE_URL=postgresql://postgres:password@localhost:5432/afl_fantasy
REDIS_URL=redis://localhost:6379

# Security (Generated secure values)
JWT_SECRET=dev-jwt-secret-change-in-production
SESSION_SECRET=dev-session-secret-change-in-production

# AFL Fantasy Credentials (Optional)
AFL_FANTASY_USERNAME=
AFL_FANTASY_PASSWORD=

# API Keys (Optional)
OPENAI_API_KEY=
GEMINI_API_KEY=

# Application Settings
NODE_ENV=development
PYTHON_ENV=development
PORT=3000
FLASK_PORT=5000

# Logging
LOG_LEVEL=debug
DEBUG=*

# Enable CORS for development
CORS_ORIGIN=*
EOF
        fi
        
        # Generate secure secrets for JWT and Session
        if command_exists openssl; then
            log "Generating secure secrets..."
            local jwt_secret=$(openssl rand -hex 32)
            local session_secret=$(openssl rand -hex 32)
            
            sed -i '' "s/JWT_SECRET=.*/JWT_SECRET=$jwt_secret/" "Shared/.env"
            sed -i '' "s/SESSION_SECRET=.*/SESSION_SECRET=$session_secret/" "Shared/.env"
            success "Generated secure JWT and session secrets"
        fi
        
        success "Environment file created at Shared/.env"
        warn "Please review and update Shared/.env with your specific values"
    else
        success "Environment file already exists"
    fi
}

# Setup Python environment
setup_python() {
    log "Setting up Python environment..."
    
    cd Python
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        log "Creating Python virtual environment..."
        python3 -m venv venv
        success "Virtual environment created"
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install dependencies
    if [ -f "requirements.txt" ]; then
        log "Installing Python dependencies..."
        pip install -r requirements.txt
        success "Python dependencies installed"
    else
        warn "No requirements.txt found, creating minimal one..."
        cat > requirements.txt << 'EOF'
Flask==3.0.0
Flask-CORS==4.0.0
numpy==1.25.2
pandas==2.1.3
scikit-learn==1.3.2
psycopg2-binary==2.9.9
redis==5.0.1
python-dotenv==1.0.0
requests==2.31.0
gunicorn==21.2.0
EOF
        pip install -r requirements.txt
        success "Installed minimal Python dependencies"
    fi
    
    # Test Python setup
    log "Testing Python setup..."
    if python -c "import flask, numpy, pandas, sklearn; print('All imports successful')"; then
        success "Python environment setup complete"
    else
        error "Python environment test failed"
        exit 1
    fi
    
    cd ..
}

# Setup Node.js environment
setup_nodejs() {
    log "Setting up Node.js environment..."
    
    cd Node
    
    # Install dependencies
    if [ -f "package.json" ]; then
        log "Installing Node.js dependencies..."
        pnpm install
        success "Node.js dependencies installed"
    else
        warn "No package.json found, creating minimal one..."
        cat > package.json << 'EOF'
{
  "name": "afl-fantasy-api",
  "version": "1.0.0",
  "description": "AFL Fantasy iOS Backend API",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsx watch src/index.ts",
    "test": "vitest",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.5"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "typescript": "^5.3.3",
    "tsx": "^4.6.2",
    "vitest": "^1.0.4",
    "eslint": "^8.56.0",
    "@typescript-eslint/parser": "^6.15.0",
    "@typescript-eslint/eslint-plugin": "^6.15.0"
  }
}
EOF
        pnpm install
        success "Installed minimal Node.js dependencies"
    fi
    
    # Build project
    if [ -f "tsconfig.json" ]; then
        log "Building TypeScript project..."
        pnpm build
        success "TypeScript build complete"
    else
        warn "No tsconfig.json found, creating minimal one..."
        cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
    fi
    
    cd ..
}

# Create development scripts
create_dev_scripts() {
    log "Creating development scripts..."
    
    # Python development script
    cat > run_python_dev.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "Starting AFL Fantasy Python API (Development Mode)"
echo "=================================================="

# Load environment variables
if [ -f "Shared/.env" ]; then
    export $(grep -v '^#' Shared/.env | xargs)
fi

# Navigate to Python directory
cd Python

# Activate virtual environment
source venv/bin/activate

# Start Flask development server
echo "🐍 Starting Python Flask API on port ${FLASK_PORT:-5000}..."
python api/trade_api.py
EOF
    
    # Node.js development script
    cat > run_node_dev.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "Starting AFL Fantasy Node.js API (Development Mode)"
echo "==================================================="

# Load environment variables
if [ -f "Shared/.env" ]; then
    export $(grep -v '^#' Shared/.env | xargs)
fi

# Navigate to Node directory
cd Node

# Start development server with hot reload
echo "🚀 Starting Node.js Express API on port ${PORT:-5000}..."
npm run dev 2>/dev/null || tsx index.ts
EOF
    
    # Combined development script
    cat > run_dev_servers.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "Starting AFL Fantasy Backend Services"
echo "===================================="

# Function to run commands in background and capture PIDs
run_service() {
    local script_name=$1
    local log_file=$2
    
    bash "$script_name" > "$log_file" 2>&1 &
    echo $!
}

# Create logs directory
mkdir -p logs

echo "🚀 Starting both Python and Node.js services..."

# Start Python service
PYTHON_PID=$(run_service "run_python_dev.sh" "logs/python_dev.log")
echo "Started Python API (PID: $PYTHON_PID) - Logs: logs/python_dev.log"

# Wait a moment for Python to start
sleep 3

# Start Node.js service
NODE_PID=$(run_service "run_node_dev.sh" "logs/node_dev.log")
echo "Started Node.js API (PID: $NODE_PID) - Logs: logs/node_dev.log"

# Save PIDs for cleanup
echo "$PYTHON_PID" > .python_dev_pid
echo "$NODE_PID" > .node_dev_pid

echo ""
echo "🎉 Both services are starting up!"
echo "📊 Python API: http://localhost:5000"
echo "🚀 Node.js API: http://localhost:5000 (or port from .env)"
echo ""
echo "📋 To view logs:"
echo "   Python: tail -f logs/python_dev.log"
echo "   Node.js: tail -f logs/node_dev.log"
echo ""
echo "🛑 To stop services: bash stop_dev_servers.sh"

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 5

# Health check
if curl -sf http://localhost:5000/health > /dev/null; then
    echo "✅ Python API is healthy"
else
    echo "❌ Python API health check failed"
fi

if curl -sf http://localhost:3000/api/health > /dev/null; then
    echo "✅ Node.js API is healthy"
else
    echo "❌ Node.js API health check failed"
fi

echo ""
echo "🎯 Development environment is ready!"
echo "Press Ctrl+C to stop all services, or run: bash stop_dev_servers.sh"

# Wait for user interrupt
trap 'bash stop_dev_servers.sh' INT
wait
EOF
    
    # Stop script
    cat > stop_dev_servers.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "🛑 Stopping AFL Fantasy Backend Services..."

# Kill Python service
if [ -f ".python_dev_pid" ]; then
    PYTHON_PID=$(cat .python_dev_pid)
    if kill -0 "$PYTHON_PID" 2>/dev/null; then
        kill "$PYTHON_PID"
        echo "Stopped Python API (PID: $PYTHON_PID)"
    fi
    rm -f .python_dev_pid
fi

# Kill Node.js service
if [ -f ".node_dev_pid" ]; then
    NODE_PID=$(cat .node_dev_pid)
    if kill -0 "$NODE_PID" 2>/dev/null; then
        kill "$NODE_PID"
        echo "Stopped Node.js API (PID: $NODE_PID)"
    fi
    rm -f .node_dev_pid
fi

# Clean up any remaining processes
pkill -f "python.*trade_api.py" 2>/dev/null || true
pkill -f "node.*dist/index.js" 2>/dev/null || true
pkill -f "tsx.*src/index.ts" 2>/dev/null || true

echo "✅ All services stopped"
EOF
    
    # Health check script
    cat > health_check.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

check_service() {
    local name=$1
    local url=$2
    
    if curl -sf "$url" > /dev/null; then
        echo "✅ $name is healthy"
        return 0
    else
        echo "❌ $name is down"
        return 1
    fi
}

echo "🏥 AFL Fantasy Backend Health Check"
echo "==================================="

check_service "Python API" "http://localhost:5000/health"
check_service "Node.js API" "http://localhost:3000/api/health"

echo ""
echo "📊 Service Status:"
lsof -ti:5000 >/dev/null && echo "  Port 5000: ✅ In use" || echo "  Port 5000: ❌ Free"
lsof -ti:3000 >/dev/null && echo "  Port 3000: ✅ In use" || echo "  Port 3000: ❌ Free"
EOF
    
    # Make all scripts executable
    chmod +x run_python_dev.sh run_node_dev.sh run_dev_servers.sh stop_dev_servers.sh health_check.sh
    
    success "Development scripts created"
}

# Main setup function
main() {
    log "Starting AFL Fantasy iOS Backend Development Setup"
    log "=================================================="
    
    # Ensure we're in the right directory
    if [ ! -d "Python" ] || [ ! -d "Node" ] || [ ! -d "Shared" ]; then
        error "Please run this script from the ios/Backend directory"
        error "Expected directories: Python, Node, Shared"
        exit 1
    fi
    
    check_prerequisites
    setup_environment
    setup_python
    setup_nodejs
    create_dev_scripts
    
    success "🎉 Development environment setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Review and update Shared/.env with your configuration"
    echo "  2. Start development servers: bash run_dev_servers.sh"
    echo "  3. Check service health: bash health_check.sh"
    echo ""
    echo "🔧 Available commands:"
    echo "  bash run_python_dev.sh     - Start only Python API"
    echo "  bash run_node_dev.sh       - Start only Node.js API"
    echo "  bash run_dev_servers.sh    - Start both APIs"
    echo "  bash stop_dev_servers.sh   - Stop all services"
    echo "  bash health_check.sh       - Check service health"
    echo ""
    echo "📚 For more information, see Documentation/DEPLOYMENT.md"
}

# Run main function
main "$@"
