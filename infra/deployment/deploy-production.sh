#!/bin/bash
# AFL Fantasy Platform - Production Deployment
# Configured for your VPS infrastructure

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ===== VPS CONFIGURATION =====
# Using your actual servers

# Primary API & Dashboard Server (Best for user-facing)
VPS_API_HOST="145.223.22.7"
VPS_API_DOMAIN="docker.sxc.codes"
VPS_API_USER="root"  # Change to your deploy user
VPS_API_PATH="/opt/afl-fantasy"

# Scraper Server (Python backend)
VPS_SCRAPER_HOST="145.223.22.9"
VPS_SCRAPER_DOMAIN="docker.tiation.net"
VPS_SCRAPER_USER="root"  # Change to your deploy user
VPS_SCRAPER_PATH="/opt/scrapers"

# Database Server (Using Supabase or standalone)
VPS_DB_HOST="93.127.167.157"
VPS_DB_DOMAIN="supabase.sxc.codes"
VPS_DB_USER="root"
VPS_DB_PATH="/var/lib/postgresql"

# Monitoring Server (Optional - Grafana)
VPS_MONITOR_HOST="153.92.214.1"
VPS_MONITOR_DOMAIN="grafana.sxc.codes"

# Elastic Search (for advanced search features)
VPS_ELASTIC_HOST="145.223.22.14"
VPS_ELASTIC_DOMAIN="elastic.sxc.codes"

# ===== DEPLOYMENT FUNCTIONS =====

print_status() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Deploy Node.js API and Dashboard to docker.sxc.codes
deploy_api_server() {
    print_status "🚀 Deploying API Server to ${VPS_API_DOMAIN}..."
    
    # Create deployment package
    print_status "Creating deployment package..."
    tar -czf /tmp/api-deploy.tar.gz \
        --exclude='node_modules' \
        --exclude='.git' \
        --exclude='*.log' \
        --exclude='dist' \
        server-node/ \
        web-client/ \
        package.json \
        package-lock.json
    
    # Transfer files
    print_status "Transferring files to ${VPS_API_DOMAIN}..."
    scp /tmp/api-deploy.tar.gz ${VPS_API_USER}@${VPS_API_HOST}:/tmp/
    
    # Deploy on server
    ssh ${VPS_API_USER}@${VPS_API_HOST} << 'ENDSSH'
        set -e
        
        # Backup existing deployment
        if [ -d /opt/afl-fantasy ]; then
            echo "Backing up existing deployment..."
            cp -r /opt/afl-fantasy /opt/afl-fantasy.backup.$(date +%Y%m%d_%H%M%S)
        fi
        
        # Create directory structure
        mkdir -p /opt/afl-fantasy
        cd /opt/afl-fantasy
        
        # Extract new deployment
        tar -xzf /tmp/api-deploy.tar.gz
        rm /tmp/api-deploy.tar.gz
        
        # Install dependencies
        echo "Installing Node.js dependencies..."
        npm ci --production
        
        # Build frontend
        echo "Building frontend..."
        npm run build:frontend || true
        
        # Setup PM2
        npm install -g pm2
        
        # Create PM2 ecosystem file
        cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'afl-api',
    script: './server-node/server/index.js',
    instances: 2,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 5000,
      DATABASE_URL: process.env.DATABASE_URL,
      PYTHON_SCRAPER_URL: 'http://145.223.22.9:8000'
    },
    error_file: '/var/log/afl-api-error.log',
    out_file: '/var/log/afl-api-out.log',
    time: true
  }, {
    name: 'afl-dashboard',
    script: 'npm',
    args: 'run dev:frontend',
    cwd: '/opt/afl-fantasy',
    env: {
      PORT: 3000
    }
  }]
};
EOF
        
        # Start services with PM2
        pm2 stop all || true
        pm2 start ecosystem.config.js
        pm2 save
        pm2 startup systemd -u root --hp /root || true
        
        echo "✅ API Server deployed successfully!"
ENDSSH
    
    print_status "✅ API deployment complete on ${VPS_API_DOMAIN}"
}

# Deploy Python Scraper to docker.tiation.net
deploy_scraper() {
    print_status "🕷️ Deploying Scraper to ${VPS_SCRAPER_DOMAIN}..."
    
    # Create scraper package
    tar -czf /tmp/scraper-deploy.tar.gz \
        --exclude='__pycache__' \
        --exclude='.git' \
        --exclude='venv' \
        --exclude='*.pyc' \
        server-python/ \
        scripts/generate_full_player_index.py \
        data/core/AFL_Fantasy_Player_URLs.xlsx
    
    # Transfer files
    print_status "Transferring scraper files to ${VPS_SCRAPER_DOMAIN}..."
    scp /tmp/scraper-deploy.tar.gz ${VPS_SCRAPER_USER}@${VPS_SCRAPER_HOST}:/tmp/
    
    # Deploy on server
    ssh ${VPS_SCRAPER_USER}@${VPS_SCRAPER_HOST} << 'ENDSSH'
        set -e
        
        # Install Python and Chrome dependencies
        apt-get update
        apt-get install -y python3-pip python3-venv chromium-browser chromium-driver xvfb supervisor
        
        # Create directory structure
        mkdir -p /opt/scrapers/data
        cd /opt/scrapers
        
        # Extract deployment
        tar -xzf /tmp/scraper-deploy.tar.gz
        rm /tmp/scraper-deploy.tar.gz
        
        # Setup Python virtual environment
        python3 -m venv venv
        source venv/bin/activate
        
        # Install Python dependencies
        pip install --upgrade pip
        pip install -r server-python/requirements.txt
        pip install gunicorn
        
        # Create systemd service for scraper API
        cat > /etc/systemd/system/afl-scraper.service << 'EOF'
[Unit]
Description=AFL Fantasy Scraper API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/scrapers/server-python
Environment="PATH=/opt/scrapers/venv/bin"
Environment="DISPLAY=:99"
ExecStartPre=/usr/bin/Xvfb :99 -screen 0 1920x1080x24 &
ExecStart=/opt/scrapers/venv/bin/python api_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        # Create supervisor config for scheduled jobs
        cat > /etc/supervisor/conf.d/afl-scheduler.conf << 'EOF'
[program:afl-scheduler]
command=/opt/scrapers/venv/bin/python /opt/scrapers/server-python/scheduler.py
directory=/opt/scrapers/server-python
autostart=true
autorestart=true
stderr_logfile=/var/log/afl-scheduler.err.log
stdout_logfile=/var/log/afl-scheduler.out.log
environment=DISPLAY=":99"
EOF
        
        # Start services
        systemctl daemon-reload
        systemctl enable afl-scraper
        systemctl restart afl-scraper
        supervisorctl reread
        supervisorctl update
        supervisorctl restart afl-scheduler || true
        
        echo "✅ Scraper deployed successfully!"
ENDSSH
    
    print_status "✅ Scraper deployment complete on ${VPS_SCRAPER_DOMAIN}"
}

# Setup Database on Supabase or dedicated server
setup_database() {
    print_status "💾 Setting up database on ${VPS_DB_DOMAIN}..."
    
    # For Supabase, we'll use the API
    # For standalone PostgreSQL, uncomment below:
    
    # ssh ${VPS_DB_USER}@${VPS_DB_HOST} << 'ENDSSH'
    #     # Create database and user
    #     sudo -u postgres psql << EOF
    #         CREATE DATABASE afl_fantasy;
    #         CREATE USER afl_user WITH ENCRYPTED PASSWORD 'secure-password-here';
    #         GRANT ALL PRIVILEGES ON DATABASE afl_fantasy TO afl_user;
    # EOF
    # ENDSSH
    
    print_status "Note: Configure Supabase database via dashboard at ${VPS_DB_DOMAIN}"
    print_status "Database connection string format:"
    echo "postgresql://[user]:[password]@${VPS_DB_HOST}:5432/afl_fantasy"
}

# Setup Nginx reverse proxy
setup_nginx() {
    print_status "🔧 Setting up Nginx on ${VPS_API_DOMAIN}..."
    
    ssh ${VPS_API_USER}@${VPS_API_HOST} << 'ENDSSH'
        # Install Nginx
        apt-get update && apt-get install -y nginx certbot python3-certbot-nginx
        
        # Create Nginx config
        cat > /etc/nginx/sites-available/afl-fantasy << 'EOF'
upstream api_backend {
    server localhost:5000;
}

upstream dashboard_backend {
    server localhost:3000;
}

server {
    listen 80;
    server_name docker.sxc.codes api.docker.sxc.codes;

    location /api {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /ws {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }

    location / {
        proxy_pass http://dashboard_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
        
        # Enable site
        ln -sf /etc/nginx/sites-available/afl-fantasy /etc/nginx/sites-enabled/
        nginx -t && systemctl reload nginx
        
        # Setup SSL with Let's Encrypt
        # certbot --nginx -d docker.sxc.codes -d api.docker.sxc.codes --non-interactive --agree-tos -m admin@sxc.codes
        
        echo "✅ Nginx configured!"
ENDSSH
}

# Health check function
health_check() {
    print_status "🏥 Running health checks..."
    
    # Check API server
    if curl -f -s "http://${VPS_API_HOST}:5000/api/health" > /dev/null; then
        print_status "✅ API Server is healthy"
    else
        print_error "API Server is not responding"
    fi
    
    # Check Scraper
    if curl -f -s "http://${VPS_SCRAPER_HOST}:8000/internal/health" > /dev/null; then
        print_status "✅ Scraper is healthy"
    else
        print_error "Scraper is not responding"
    fi
    
    # Check Dashboard
    if curl -f -s "http://${VPS_API_HOST}:3000" > /dev/null; then
        print_status "✅ Dashboard is accessible"
    else
        print_warning "Dashboard might still be building..."
    fi
}

# Show logs
show_logs() {
    case "$1" in
        api)
            print_status "📜 API Server logs:"
            ssh ${VPS_API_USER}@${VPS_API_HOST} "pm2 logs afl-api --lines 50"
            ;;
        scraper)
            print_status "📜 Scraper logs:"
            ssh ${VPS_SCRAPER_USER}@${VPS_SCRAPER_HOST} "journalctl -u afl-scraper -n 50"
            ;;
        *)
            print_error "Usage: $0 logs {api|scraper}"
            ;;
    esac
}

# Main deployment menu
print_status "🏈 AFL Fantasy Platform Deployment"
print_status "=================================="
echo ""
echo "Available servers:"
echo "  API/Dashboard: ${VPS_API_DOMAIN} (${VPS_API_HOST})"
echo "  Scraper:       ${VPS_SCRAPER_DOMAIN} (${VPS_SCRAPER_HOST})"
echo "  Database:      ${VPS_DB_DOMAIN} (${VPS_DB_HOST})"
echo "  Monitoring:    ${VPS_MONITOR_DOMAIN} (${VPS_MONITOR_HOST})"
echo ""

case "$1" in
    all)
        deploy_api_server
        deploy_scraper
        setup_nginx
        health_check
        ;;
    api)
        deploy_api_server
        ;;
    scraper)
        deploy_scraper
        ;;
    nginx)
        setup_nginx
        ;;
    db)
        setup_database
        ;;
    health)
        health_check
        ;;
    logs)
        show_logs "$2"
        ;;
    *)
        echo "Usage: $0 {all|api|scraper|nginx|db|health|logs [api|scraper]}"
        echo ""
        echo "Examples:"
        echo "  $0 all        # Deploy everything"
        echo "  $0 api        # Deploy only API/Dashboard"
        echo "  $0 scraper    # Deploy only scraper"
        echo "  $0 health     # Check service health"
        echo "  $0 logs api   # View API logs"
        exit 1
        ;;
esac

print_status "Deployment script completed!"
