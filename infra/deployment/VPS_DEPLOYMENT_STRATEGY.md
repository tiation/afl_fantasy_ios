# AFL Fantasy Platform - Multi-VPS Deployment Strategy

**Date:** 2025-01-10  
**Architecture:** Distributed Microservices across Multiple VPS

## VPS Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENTS                              │
│        iOS App | Web Dashboard | Admin Panel                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────────┐
        │     Load Balancer / Nginx       │
        │      (VPS-1 or CloudFlare)      │
        └──────┬────────────┬─────────────┘
               │            │
     ┌─────────▼────┐   ┌──▼──────────┐
     │    VPS-1     │   │    VPS-2     │
     │  API Server  │   │   Scraper    │
     │   (Node.js)  │   │   (Python)   │
     │   Port 5000  │   │  Port 8000   │
     └──────┬───────┘   └──────┬───────┘
            │                  │
            └──────┬───────────┘
                   ▼
        ┌─────────────────────────┐
        │        VPS-3            │
        │     PostgreSQL DB       │
        │      Redis Cache        │
        │      Port 5432/6379     │
        └─────────────────────────┘
```

## VPS Allocation Strategy

### VPS-1: API & Dashboard Server
- **Role:** Primary API server and web dashboard
- **Services:**
  - Node.js API (Port 5000)
  - Web Dashboard (Port 3000)
  - WebSocket Server (Port 5001)
  - Nginx Reverse Proxy (Port 80/443)
- **Resources:** 2GB RAM, 2 vCPU
- **Location:** Closest to majority of users

### VPS-2: Scraper & Data Processing
- **Role:** Web scraping and data processing
- **Services:**
  - Python Scraper Service (Port 8000)
  - Scheduled Jobs (Cron)
  - Data Processing Pipeline
  - Backup Scraper Instance
- **Resources:** 4GB RAM, 2 vCPU (needs more RAM for Selenium)
- **Location:** Any stable location

### VPS-3: Database & Cache
- **Role:** Data persistence and caching
- **Services:**
  - PostgreSQL Database (Port 5432)
  - Redis Cache (Port 6379)
  - Backup Service
- **Resources:** 2GB RAM, 2 vCPU, 50GB SSD
- **Location:** Same region as VPS-1 for low latency

### VPS-4: Backup/Staging (Optional)
- **Role:** Staging environment and failover
- **Services:** Mirror of VPS-1
- **Resources:** 1GB RAM, 1 vCPU
- **Location:** Different region for redundancy

## Deployment Scripts

### 1. Master Deployment Script
Save as `deployment/deploy-to-vps.sh`:

```bash
#!/bin/bash
# Multi-VPS Deployment Orchestrator

# VPS Configuration
VPS1_HOST="vps1.yourdomain.com"
VPS1_USER="deploy"
VPS1_PATH="/var/www/afl-fantasy"

VPS2_HOST="vps2.yourdomain.com"
VPS2_USER="deploy"
VPS2_PATH="/opt/scrapers"

VPS3_HOST="vps3.yourdomain.com"
VPS3_USER="deploy"
VPS3_PATH="/var/lib/postgresql"

# Deployment functions
deploy_api_server() {
    echo "🚀 Deploying API Server to VPS-1..."
    rsync -avz --exclude 'node_modules' --exclude '.git' \
        ./server-node/ $VPS1_USER@$VPS1_HOST:$VPS1_PATH/server-node/
    
    ssh $VPS1_USER@$VPS1_HOST << 'EOF'
        cd /var/www/afl-fantasy/server-node
        npm install --production
        pm2 restart afl-api || pm2 start npm --name "afl-api" -- start
EOF
}

deploy_scraper() {
    echo "🕷️ Deploying Scraper to VPS-2..."
    rsync -avz --exclude '__pycache__' --exclude '.git' \
        ./server-python/ $VPS2_USER@$VPS2_HOST:$VPS2_PATH/
    
    ssh $VPS2_USER@$VPS2_HOST << 'EOF'
        cd /opt/scrapers
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
        supervisorctl restart afl-scraper
EOF
}

deploy_database() {
    echo "💾 Updating Database Schema on VPS-3..."
    scp ./database/migrations/*.sql $VPS3_USER@$VPS3_HOST:/tmp/
    
    ssh $VPS3_USER@$VPS3_HOST << 'EOF'
        psql -U postgres -d afl_fantasy < /tmp/migrations.sql
EOF
}

# Main deployment
case "$1" in
    all)
        deploy_api_server
        deploy_scraper
        deploy_database
        ;;
    api)
        deploy_api_server
        ;;
    scraper)
        deploy_scraper
        ;;
    db)
        deploy_database
        ;;
    *)
        echo "Usage: $0 {all|api|scraper|db}"
        exit 1
        ;;
esac
```

### 2. Service Start Scripts

#### VPS-1: API Server (`start-api-vps1.sh`)
```bash
#!/bin/bash
# Start script for VPS-1 (API Server)

# Start Node.js API
cd /var/www/afl-fantasy/server-node
pm2 start ecosystem.config.js

# Start Nginx
sudo systemctl start nginx

# Start Redis (local cache)
redis-server --daemonize yes

echo "✅ VPS-1 Services Started"
```

#### VPS-2: Scraper (`start-scraper-vps2.sh`)
```bash
#!/bin/bash
# Start script for VPS-2 (Scraper)

cd /opt/scrapers
source venv/bin/activate

# Start Python API server
nohup python api_server.py > scraper.log 2>&1 &

# Start scheduler
nohup python scheduler.py > scheduler.log 2>&1 &

# Start Chrome for Selenium
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99

echo "✅ VPS-2 Scraper Services Started"
```

#### VPS-3: Database (`start-db-vps3.sh`)
```bash
#!/bin/bash
# Start script for VPS-3 (Database)

# Start PostgreSQL
sudo systemctl start postgresql

# Start Redis
redis-server /etc/redis/redis.conf

# Start backup cron
crontab -l | { cat; echo "0 2 * * * /opt/backup/backup-db.sh"; } | crontab -

echo "✅ VPS-3 Database Services Started"
```

## Environment Configuration

### `.env` for each VPS:

#### VPS-1 (.env.production)
```env
NODE_ENV=production
PORT=5000
DASHBOARD_PORT=3000
DATABASE_URL=postgresql://afl_user:password@VPS3_IP:5432/afl_fantasy
REDIS_URL=redis://VPS3_IP:6379
PYTHON_SCRAPER_URL=http://VPS2_IP:8000
JWT_SECRET=your-secret-key
```

#### VPS-2 (.env.scraper)
```env
ENVIRONMENT=production
DATABASE_URL=postgresql://afl_user:password@VPS3_IP:5432/afl_fantasy
REDIS_URL=redis://VPS3_IP:6379
SCRAPER_PORT=8000
SELENIUM_HEADLESS=true
MAX_WORKERS=4
```

#### VPS-3 (.env.database)
```env
POSTGRES_DB=afl_fantasy
POSTGRES_USER=afl_user
POSTGRES_PASSWORD=secure-password
REDIS_PASSWORD=redis-password
BACKUP_PATH=/backups
```

## Service Management

### Using PM2 (Node.js)
```javascript
// ecosystem.config.js for VPS-1
module.exports = {
  apps: [{
    name: 'afl-api',
    script: './server/index.js',
    instances: 2,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 5000
    }
  }, {
    name: 'afl-dashboard',
    script: 'npm',
    args: 'run dev:frontend',
    env: {
      PORT: 3000
    }
  }]
};
```

### Using Supervisor (Python)
```ini
# /etc/supervisor/conf.d/afl-scraper.conf for VPS-2
[program:afl-scraper]
command=/opt/scrapers/venv/bin/python /opt/scrapers/api_server.py
directory=/opt/scrapers
autostart=true
autorestart=true
stderr_logfile=/var/log/afl-scraper.err.log
stdout_logfile=/var/log/afl-scraper.out.log
```

## Nginx Configuration (VPS-1)

```nginx
# /etc/nginx/sites-available/afl-fantasy
upstream api_backend {
    server localhost:5000;
}

upstream dashboard_backend {
    server localhost:3000;
}

server {
    listen 80;
    server_name api.aflfattasy.com;

    location / {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /ws {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}

server {
    listen 80;
    server_name dashboard.aflfantasy.com;

    location / {
        proxy_pass http://dashboard_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Monitoring & Health Checks

### Health Check Script (`health-check.sh`)
```bash
#!/bin/bash
# Run on monitoring VPS or locally

check_service() {
    local url=$1
    local name=$2
    
    if curl -f -s "$url" > /dev/null; then
        echo "✅ $name is healthy"
    else
        echo "❌ $name is down!"
        # Send alert (email, Slack, etc.)
    fi
}

# Check all services
check_service "http://VPS1_IP:5000/api/health" "API Server"
check_service "http://VPS2_IP:8000/internal/health" "Scraper"
check_service "http://VPS3_IP:5432" "PostgreSQL"

# Check scraper job status
SCRAPER_STATUS=$(curl -s http://VPS2_IP:8000/internal/status | jq -r '.status')
echo "📊 Scraper Status: $SCRAPER_STATUS"
```

## Deployment Checklist

### Initial Setup (One-time)
- [ ] Set up SSH keys for all VPS servers
- [ ] Install required software on each VPS
- [ ] Configure firewalls (UFW/iptables)
- [ ] Set up SSL certificates (Let's Encrypt)
- [ ] Configure backup scripts
- [ ] Set up monitoring (Prometheus/Grafana optional)

### Per Deployment
- [ ] Run tests locally
- [ ] Update version numbers
- [ ] Deploy to staging (VPS-4) first
- [ ] Run integration tests on staging
- [ ] Deploy to production VPS servers
- [ ] Verify health checks
- [ ] Monitor logs for errors

## Quick Commands

```bash
# Deploy everything
./deployment/deploy-to-vps.sh all

# Deploy only API updates
./deployment/deploy-to-vps.sh api

# Deploy only scraper updates
./deployment/deploy-to-vps.sh scraper

# Check all services
./deployment/health-check.sh

# View logs
ssh vps1 "pm2 logs afl-api"
ssh vps2 "tail -f /var/log/afl-scraper.out.log"
ssh vps3 "tail -f /var/log/postgresql/postgresql-*.log"

# Restart services
ssh vps1 "pm2 restart all"
ssh vps2 "supervisorctl restart afl-scraper"
ssh vps3 "systemctl restart postgresql"
```

---

*This deployment strategy ensures high availability, scalability, and maintainability across your VPS infrastructure.*
