#!/bin/bash
# AFL Fantasy Platform - Docker Deployment
# Optimized for your Ubuntu 24.04 VPS servers with Docker

set -e

# Configuration
PROJECT_NAME="afl-fantasy"
DEPLOY_USER="root"  # Change if using non-root user

# Your VPS servers (all have Docker)
VPS_OPTIONS=(
    "docker.sxc.codes:145.223.22.7"
    "docker.tiation.net:145.223.22.9"
    "srv634730.hstgr.cloud:148.230.88.200"  # KVM 8 - Most powerful
)

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# Select deployment server
select_server() {
    echo "Select deployment server:"
    echo ""
    for i in "${!VPS_OPTIONS[@]}"; do
        IFS=':' read -r domain ip <<< "${VPS_OPTIONS[$i]}"
        echo "  $((i+1)). $domain ($ip)"
    done
    echo ""
    read -p "Enter choice (1-${#VPS_OPTIONS[@]}): " choice
    
    if [[ $choice -lt 1 || $choice -gt ${#VPS_OPTIONS[@]} ]]; then
        print_error "Invalid choice"
        exit 1
    fi
    
    IFS=':' read -r DEPLOY_DOMAIN DEPLOY_HOST <<< "${VPS_OPTIONS[$((choice-1))]}"
    print_status "Deploying to $DEPLOY_DOMAIN ($DEPLOY_HOST)"
}

# Deploy to selected VPS
deploy_to_vps() {
    print_status "Starting deployment to $DEPLOY_DOMAIN..."
    
    # Create deployment archive
    print_status "Creating deployment package..."
    # Avoid macOS extended attributes in tarball to reduce noisy warnings on Linux
    COPYFILE_DISABLE=1 tar -czf /tmp/afl-deploy.tar.gz \
        --exclude='node_modules' \
        --exclude='__pycache__' \
        --exclude='.git' \
        --exclude='*.log' \
        --exclude='venv' \
        --exclude='dist' \
        --exclude='ios' \
        --exclude='archive' \
        docker-compose.production.yml \
        server-node/ \
        server-python/ \
        web-client/ \
        data/ \
        nginx/ \
        deployment/.env.production \
        package*.json
    
    # Transfer to server
    print_status "Transferring files to $DEPLOY_DOMAIN..."
    scp /tmp/afl-deploy.tar.gz $DEPLOY_USER@$DEPLOY_HOST:/tmp/
    rm /tmp/afl-deploy.tar.gz
    
    # Deploy on server
    ssh $DEPLOY_USER@$DEPLOY_HOST << 'ENDSSH'
        set -e
        
        # Colors for remote output
        GREEN='\033[0;32m'
        NC='\033[0m'
        
        echo -e "${GREEN}[Remote]${NC} Setting up deployment..."
        
        # Create project directory
        mkdir -p /opt/afl-fantasy
        cd /opt/afl-fantasy
        
        # Backup existing deployment
        if [ -f docker-compose.production.yml ]; then
            echo "Backing up existing deployment..."
            docker-compose -f docker-compose.production.yml down || true
            mv docker-compose.production.yml docker-compose.backup.$(date +%Y%m%d_%H%M%S).yml
        fi
        
        # Extract new deployment
        tar -xzf /tmp/afl-deploy.tar.gz
        rm /tmp/afl-deploy.tar.gz
        
        # Setup environment
        if [ ! -f .env ]; then
            cp deployment/.env.production .env
            echo "⚠️  Please edit .env file with your actual credentials!"
        fi
        
        # Pull/build Docker images
        echo "Building Docker images..."
        docker-compose -f docker-compose.production.yml build
        
        # Start services
        echo "Starting services..."
        docker-compose -f docker-compose.production.yml up -d
        
        # Wait for services to start
        sleep 10
        
        # Check service status
        echo ""
        echo "Service Status:"
        docker-compose -f docker-compose.production.yml ps
        
        echo ""
        echo "✅ Deployment complete!"
ENDSSH
    
    print_status "Deployment successful!"
    echo ""
    echo "Services are available at:"
    echo "  Dashboard: http://$DEPLOY_DOMAIN"
    echo "  API:       http://$DEPLOY_DOMAIN/api"
    echo "  Scraper:   http://$DEPLOY_HOST:8000 (internal)"
    echo ""
}

# Service management commands
manage_services() {
    case "$1" in
        start)
            ssh $DEPLOY_USER@$DEPLOY_HOST "cd /opt/afl-fantasy && docker-compose -f docker-compose.production.yml up -d"
            print_status "Services started"
            ;;
        stop)
            ssh $DEPLOY_USER@$DEPLOY_HOST "cd /opt/afl-fantasy && docker-compose -f docker-compose.production.yml down"
            print_status "Services stopped"
            ;;
        restart)
            ssh $DEPLOY_USER@$DEPLOY_HOST "cd /opt/afl-fantasy && docker-compose -f docker-compose.production.yml restart"
            print_status "Services restarted"
            ;;
        logs)
            ssh $DEPLOY_USER@$DEPLOY_HOST "cd /opt/afl-fantasy && docker-compose -f docker-compose.production.yml logs -f --tail=100 $2"
            ;;
        status)
            ssh $DEPLOY_USER@$DEPLOY_HOST "cd /opt/afl-fantasy && docker-compose -f docker-compose.production.yml ps"
            ;;
        exec)
            ssh $DEPLOY_USER@$DEPLOY_HOST "cd /opt/afl-fantasy && docker-compose -f docker-compose.production.yml exec $2 ${@:3}"
            ;;
        *)
            print_error "Unknown command: $1"
            ;;
    esac
}

# Health check
health_check() {
    print_status "Running health checks on $DEPLOY_DOMAIN..."
    
    # Check API
    if curl -f -s "http://$DEPLOY_HOST:5000/api/health" > /dev/null 2>&1; then
        print_status "API is healthy"
    else
        print_error "API is not responding"
    fi
    
    # Check Scraper
    if curl -f -s "http://$DEPLOY_HOST:8000/internal/health" > /dev/null 2>&1; then
        print_status "Scraper is healthy"
    else
        print_error "Scraper is not responding"
    fi
    
    # Check Dashboard
    if curl -f -s "http://$DEPLOY_HOST" > /dev/null 2>&1; then
        print_status "Dashboard is accessible"
    else
        print_warning "Dashboard might still be building..."
    fi
    
    # Check Docker containers
    echo ""
    print_status "Docker container status:"
    ssh $DEPLOY_USER@$DEPLOY_HOST "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
}

# Main script
echo "🏈 AFL Fantasy Platform - Docker Deployment"
echo "=========================================="
echo ""

# Parse command
case "$1" in
    deploy)
        select_server
        deploy_to_vps
        health_check
        ;;
    quick)
        # Quick deploy to most powerful server
        DEPLOY_DOMAIN="srv634730.hstgr.cloud"
        DEPLOY_HOST="148.230.88.200"
        print_status "Quick deploy to $DEPLOY_DOMAIN (KVM 8)"
        deploy_to_vps
        health_check
        ;;
    manage)
        if [ -z "$2" ]; then
            echo "Usage: $0 manage {start|stop|restart|logs|status|exec} [service]"
            exit 1
        fi
        select_server
        manage_services "$2" "$3" "${@:4}"
        ;;
    health)
        select_server
        health_check
        ;;
    ssh)
        select_server
        print_status "Connecting to $DEPLOY_DOMAIN..."
        ssh $DEPLOY_USER@$DEPLOY_HOST
        ;;
    *)
        echo "Usage: $0 {deploy|quick|manage|health|ssh}"
        echo ""
        echo "Commands:"
        echo "  deploy  - Deploy to selected VPS"
        echo "  quick   - Quick deploy to most powerful server"
        echo "  manage  - Manage services (start/stop/restart/logs/status)"
        echo "  health  - Check service health"
        echo "  ssh     - SSH into selected server"
        echo ""
        echo "Examples:"
        echo "  $0 deploy                    # Interactive deployment"
        echo "  $0 quick                     # Deploy to srv634730 (8GB RAM)"
        echo "  $0 manage logs api           # View API logs"
        echo "  $0 manage restart scraper    # Restart scraper"
        echo "  $0 health                    # Check all services"
        exit 1
        ;;
esac
