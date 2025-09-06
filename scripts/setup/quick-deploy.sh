#!/bin/bash

# AFL Fantasy Platform - Quick Deploy Script
# One-command deployment with multiple options

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${PURPLE}"
cat << "EOF"
    ___    __________ 
   /   |  / ____/ __ \
  / /| | / /_  / / / /
 / ___ |/ __/ / /_/ / 
/_/  |_/_/    \____/  
                      
Fantasy Intelligence Platform
EOF
echo -e "${NC}"

echo -e "${CYAN}🏆 AFL Fantasy Intelligence Platform - Quick Deploy${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check system requirements
check_requirements() {
    echo -e "${YELLOW}📋 Checking system requirements...${NC}"
    
    # Check available memory (Linux/macOS)
    if command_exists free; then
        MEM_AVAILABLE=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    elif command_exists vm_stat; then
        # macOS
        MEM_AVAILABLE=$(vm_stat | grep "Pages free" | awk '{print int($3) * 4 / 1024}')
    else
        MEM_AVAILABLE=4000 # Assume sufficient if can't check
    fi
    
    # Check disk space
    DISK_AVAILABLE=$(df . | tail -1 | awk '{print int($4/1024)}')
    
    echo -e "  ${GREEN}✓${NC} Memory Available: ${MEM_AVAILABLE}MB (need 2GB)"
    echo -e "  ${GREEN}✓${NC} Disk Available: ${DISK_AVAILABLE}MB (need 5GB)"
    
    if [ "$MEM_AVAILABLE" -lt 2000 ]; then
        echo -e "  ${RED}⚠ Warning: Low memory may affect performance${NC}"
    fi
    
    if [ "$DISK_AVAILABLE" -lt 5000 ]; then
        echo -e "  ${RED}⚠ Warning: Low disk space may cause issues${NC}"
    fi
    
    echo ""
}

# Function to install Docker if needed
install_docker() {
    if ! command_exists docker; then
        echo -e "${YELLOW}📦 Docker not found. Installing Docker...${NC}"
        
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker $USER
            rm get-docker.sh
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            echo -e "${RED}Please install Docker Desktop from: https://docs.docker.com/desktop/mac/install/${NC}"
            exit 1
        else
            echo -e "${RED}Unsupported OS. Please install Docker manually.${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}✓ Docker installed successfully${NC}"
    else
        echo -e "${GREEN}✓ Docker found${NC}"
    fi
    
    if ! command_exists docker-compose; then
        echo -e "${YELLOW}📦 Installing Docker Compose...${NC}"
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo -e "${GREEN}✓ Docker Compose installed${NC}"
    else
        echo -e "${GREEN}✓ Docker Compose found${NC}"
    fi
}

# Function to setup environment
setup_environment() {
    echo -e "${YELLOW}🔧 Setting up environment...${NC}"
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            echo -e "  ${GREEN}✓${NC} Created .env from .env.example"
        else
            cat > .env << EOF
NODE_ENV=development
PORT=5000
DATABASE_URL=postgresql://postgres:aflpassword@postgres:5432/afl_fantasy
SESSION_SECRET=your-secret-key-change-in-production
CORS_ORIGIN=http://localhost:5000
EOF
            echo -e "  ${GREEN}✓${NC} Created default .env file"
        fi
    else
        echo -e "  ${GREEN}✓${NC} .env file already exists"
    fi
    
    echo ""
}

# Function to deploy with Docker Compose
deploy_docker_compose() {
    echo -e "${BLUE}🐳 Deploying with Docker Compose...${NC}"
    
    # Pull latest images
    echo -e "  ${YELLOW}📥 Pulling Docker images...${NC}"
    docker-compose pull
    
    # Build and start services
    echo -e "  ${YELLOW}🔨 Building and starting services...${NC}"
    docker-compose up -d --build
    
    # Wait for services to be ready
    echo -e "  ${YELLOW}⏳ Waiting for services to start...${NC}"
    sleep 10
    
    # Health check
    echo -e "  ${YELLOW}🩺 Checking service health...${NC}"
    for i in {1..30}; do
        if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Application is healthy!"
            break
        fi
        if [ $i -eq 30 ]; then
            echo -e "  ${RED}✗${NC} Health check failed. Check logs with: docker-compose logs"
            exit 1
        fi
        echo -n "."
        sleep 2
    done
    
    echo ""
    echo -e "${GREEN}🎉 Docker Compose deployment complete!${NC}"
}

# Function to deploy with npm (development)
deploy_npm() {
    echo -e "${BLUE}📦 Deploying with npm (development mode)...${NC}"
    
    # Check Node.js
    if ! command_exists node; then
        echo -e "${RED}Node.js not found. Please install Node.js 20+ first.${NC}"
        exit 1
    fi
    
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        echo -e "${RED}Node.js version $NODE_VERSION is too old. Please install Node.js 18+${NC}"
        exit 1
    fi
    
    echo -e "  ${GREEN}✓${NC} Node.js $(node -v) found"
    
    # Install dependencies
    echo -e "  ${YELLOW}📥 Installing dependencies...${NC}"
    npm install
    
    # Start development server
    echo -e "  ${YELLOW}🚀 Starting development server...${NC}"
    npm run dev &
    SERVER_PID=$!
    
    # Wait for server to start
    echo -e "  ${YELLOW}⏳ Waiting for server to start...${NC}"
    sleep 5
    
    # Health check
    for i in {1..15}; do
        if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Server is running!"
            break
        fi
        if [ $i -eq 15 ]; then
            echo -e "  ${RED}✗${NC} Server failed to start. Check logs."
            kill $SERVER_PID 2>/dev/null || true
            exit 1
        fi
        echo -n "."
        sleep 2
    done
    
    echo ""
    echo -e "${GREEN}🎉 Development server started!${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
    
    # Keep script running
    wait $SERVER_PID
}

# Function to deploy with Kubernetes
deploy_kubernetes() {
    echo -e "${BLUE}⎈ Deploying with Kubernetes...${NC}"
    
    # Check kubectl
    if ! command_exists kubectl; then
        echo -e "${RED}kubectl not found. Please install kubectl first.${NC}"
        exit 1
    fi
    
    # Check if k8s directory exists
    if [ ! -d "k8s" ]; then
        echo -e "${RED}k8s directory not found. Kubernetes manifests are required.${NC}"
        exit 1
    fi
    
    # Apply manifests
    echo -e "  ${YELLOW}📋 Applying Kubernetes manifests...${NC}"
    kubectl apply -f k8s/
    
    # Wait for deployment
    echo -e "  ${YELLOW}⏳ Waiting for deployment to be ready...${NC}"
    kubectl wait --for=condition=available --timeout=300s deployment/afl-fantasy-app -n afl-fantasy
    
    # Port forward for testing
    echo -e "  ${YELLOW}🔌 Setting up port forwarding...${NC}"
    kubectl port-forward svc/afl-fantasy-service 5000:5000 -n afl-fantasy &
    PORT_FORWARD_PID=$!
    
    sleep 5
    
    # Health check
    if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Kubernetes deployment successful!"
    else
        echo -e "  ${RED}✗${NC} Deployment health check failed"
        kill $PORT_FORWARD_PID 2>/dev/null || true
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Kubernetes deployment complete!${NC}"
    echo -e "${YELLOW}Port forwarding active. Press Ctrl+C to stop.${NC}"
    
    # Keep port forwarding active
    wait $PORT_FORWARD_PID
}

# Function to deploy with Helm
deploy_helm() {
    echo -e "${BLUE}⛵ Deploying with Helm...${NC}"
    
    # Check helm
    if ! command_exists helm; then
        echo -e "${RED}Helm not found. Please install Helm first.${NC}"
        exit 1
    fi
    
    # Check if helm directory exists
    if [ ! -d "helm/afl-fantasy-platform" ]; then
        echo -e "${RED}Helm chart not found at helm/afl-fantasy-platform${NC}"
        exit 1
    fi
    
    # Install or upgrade
    echo -e "  ${YELLOW}⛵ Installing/upgrading Helm release...${NC}"
    helm upgrade --install afl-fantasy-platform ./helm/afl-fantasy-platform \
        --create-namespace \
        --namespace afl-fantasy \
        --wait \
        --timeout=10m
    
    # Port forward for testing
    echo -e "  ${YELLOW}🔌 Setting up port forwarding...${NC}"
    kubectl port-forward svc/afl-fantasy-platform 5000:5000 -n afl-fantasy &
    PORT_FORWARD_PID=$!
    
    sleep 5
    
    # Health check
    if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Helm deployment successful!"
    else
        echo -e "  ${RED}✗${NC} Deployment health check failed"
        kill $PORT_FORWARD_PID 2>/dev/null || true
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Helm deployment complete!${NC}"
    echo -e "${YELLOW}Port forwarding active. Press Ctrl+C to stop.${NC}"
    
    # Keep port forwarding active
    wait $PORT_FORWARD_PID
}

# Function to show deployment info
show_deployment_info() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 AFL Fantasy Platform is now running!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}📊 Access your platform:${NC}"
    echo -e "  🌐 Application: ${GREEN}http://localhost:5000${NC}"
    echo -e "  📈 API Health: ${GREEN}http://localhost:5000/api/health${NC}"
    echo -e "  📋 API Stats: ${GREEN}http://localhost:5000/api/stats/combined-stats${NC}"
    echo ""
    echo -e "${BLUE}🛠️ Platform Features:${NC}"
    echo -e "  ✅ 642 Authentic AFL Players"
    echo -e "  ✅ 25+ Fantasy Analysis Tools"
    echo -e "  ✅ Real-time Score Projections"
    echo -e "  ✅ Trade Calculator & Risk Analysis"
    echo -e "  ✅ Captain Selection Optimizer"
    echo -e "  ✅ Cash Generation Tracker"
    echo ""
    echo -e "${BLUE}📚 Quick Start:${NC}"
    echo -e "  1. Visit ${GREEN}http://localhost:5000${NC}"
    echo -e "  2. Explore the Dashboard and Stats pages"
    echo -e "  3. Try the Fantasy Tools for advanced analysis"
    echo -e "  4. Use the Trade Calculator for trade decisions"
    echo ""
    echo -e "${YELLOW}💡 Need help?${NC}"
    echo -e "  📖 Documentation: ./DOWNLOAD_AND_DEPLOY.md"
    echo -e "  🐛 Issues: https://github.com/your-username/afl-fantasy-platform/issues"
    echo -e "  💬 Discussions: https://github.com/your-username/afl-fantasy-platform/discussions"
    echo ""
}

# Function to handle cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}🧹 Cleaning up...${NC}"
    # Kill any background processes
    jobs -p | xargs -r kill 2>/dev/null || true
}

# Trap cleanup on exit
trap cleanup EXIT

# Main menu
main_menu() {
    echo -e "${BLUE}🚀 Choose your deployment method:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Docker Compose ${YELLOW}(Recommended - Easy setup)${NC}"
    echo -e "  ${GREEN}2)${NC} NPM Development ${YELLOW}(Local development)${NC}" 
    echo -e "  ${GREEN}3)${NC} Kubernetes ${YELLOW}(Production scaling)${NC}"
    echo -e "  ${GREEN}4)${NC} Helm Charts ${YELLOW}(Enterprise deployment)${NC}"
    echo -e "  ${GREEN}5)${NC} Exit"
    echo ""
    
    while true; do
        read -p "$(echo -e ${CYAN}Choose an option [1-5]: ${NC})" choice
        case $choice in
            1)
                check_requirements
                install_docker
                setup_environment
                deploy_docker_compose
                show_deployment_info
                break
                ;;
            2)
                check_requirements
                setup_environment
                deploy_npm
                break
                ;;
            3)
                check_requirements
                deploy_kubernetes
                show_deployment_info
                break
                ;;
            4)
                check_requirements
                deploy_helm
                show_deployment_info
                break
                ;;
            5)
                echo -e "${YELLOW}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please choose 1-5.${NC}"
                ;;
        esac
    done
}

# Handle command line arguments
if [ "$#" -eq 0 ]; then
    # No arguments, show menu
    main_menu
else
    case "$1" in
        "docker")
            check_requirements
            install_docker
            setup_environment
            deploy_docker_compose
            show_deployment_info
            ;;
        "npm")
            check_requirements
            setup_environment
            deploy_npm
            ;;
        "k8s"|"kubernetes")
            check_requirements
            deploy_kubernetes
            show_deployment_info
            ;;
        "helm")
            check_requirements
            deploy_helm
            show_deployment_info
            ;;
        "help"|"-h"|"--help")
            echo "AFL Fantasy Platform - Quick Deploy"
            echo ""
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  docker      Deploy with Docker Compose"
            echo "  npm         Deploy with npm (development)"
            echo "  kubernetes  Deploy with Kubernetes"
            echo "  helm        Deploy with Helm"
            echo "  help        Show this help message"
            echo ""
            echo "If no option is provided, an interactive menu will be shown."
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Run '$0 help' for available options."
            exit 1
            ;;
    esac
fi