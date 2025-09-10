# AFL Fantasy iOS Backend - Deployment Guide

## Overview
This guide covers deployment strategies for both development and production environments of the AFL Fantasy iOS backend services.

## Prerequisites

### System Requirements
- **Python**: 3.13 or higher
- **Node.js**: 20 or higher  
- **PostgreSQL**: 14 or higher
- **Redis**: 7 or higher (optional for development)
- **Memory**: Minimum 4GB RAM, recommended 8GB+
- **Storage**: Minimum 10GB free space

### Development Tools
- **pnpm**: Package manager for Node.js
- **pip**: Python package manager
- **Git**: Version control
- **Docker** (optional): For containerized deployment

## Environment Setup

### 1. Clone and Navigate
```bash
cd /path/to/project/ios/Backend
```

### 2. Environment Variables
Copy and configure environment variables:
```bash
cp Shared/.env.example Shared/.env
```

Edit `Shared/.env` with your specific values:
```bash
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/afl_fantasy
REDIS_URL=redis://localhost:6379

# Security (Generate secure values)
JWT_SECRET=$(openssl rand -hex 32)
SESSION_SECRET=$(openssl rand -hex 32)

# AFL Fantasy Credentials (Optional)
AFL_FANTASY_USERNAME=your_afl_username
AFL_FANTASY_PASSWORD=your_afl_password

# API Keys (Optional)
OPENAI_API_KEY=sk-your-openai-key
GEMINI_API_KEY=your-gemini-key

# Application Settings
NODE_ENV=development
PYTHON_ENV=development
PORT=3000
FLASK_PORT=5000
```

### 3. Database Setup
```bash
# Create database
createdb afl_fantasy

# Verify connection
psql afl_fantasy -c "SELECT 1;"
```

## Development Deployment

### Python Flask Service

#### Setup Virtual Environment
```bash
cd Python
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

#### Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### Run Development Server
```bash
# Load environment variables
export $(grep -v '^#' ../Shared/.env | xargs)

# Start Flask development server
python api/trade_api.py
```

**Service will be available at**: `http://localhost:5000`

### Node.js Express Service

#### Install Dependencies
```bash
cd Node
pnpm install
```

#### Build and Run
```bash
# Build TypeScript
pnpm build

# Start development server
pnpm dev
```

**Service will be available at**: `http://localhost:3000`

### Verification
```bash
# Test Python service
curl http://localhost:5000/health

# Test Node.js service  
curl http://localhost:3000/api/health
```

## Production Deployment

### Option 1: Traditional Server Deployment

#### Python Service (using Gunicorn)
```bash
cd Python

# Install production server
pip install gunicorn

# Create Gunicorn configuration
cat > gunicorn.conf.py << 'EOF'
bind = "0.0.0.0:5000"
workers = 4
worker_class = "sync"
timeout = 120
keepalive = 5
max_requests = 1000
max_requests_jitter = 100
preload_app = True
EOF

# Start production server
gunicorn --config gunicorn.conf.py api.trade_api:app
```

#### Node.js Service (using PM2)
```bash
cd Node

# Install PM2 globally
npm install -g pm2

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'afl-fantasy-api',
    script: 'dist/index.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
EOF

# Create logs directory
mkdir -p logs

# Start with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Option 2: Docker Deployment

#### Create Docker Files

**Python Dockerfile** (`Python/Dockerfile`):
```dockerfile
FROM python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "api.trade_api:app"]
```

**Node.js Dockerfile** (`Node/Dockerfile`):
```dockerfile
FROM node:20-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files
COPY package*.json pnpm-lock.yaml* ./

# Install dependencies
RUN pnpm install --frozen-lockfile --prod

# Copy source code
COPY . .

# Build application
RUN pnpm build

# Expose port
EXPOSE 3000

# Start application
CMD ["pnpm", "start"]
```

#### Docker Compose Setup
Create `docker-compose.yml` in the Backend root:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: afl_fantasy
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

  python-api:
    build: ./Python
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/afl_fantasy
      - REDIS_URL=redis://redis:6379
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    volumes:
      - ./Shared/.env:/app/.env
    restart: unless-stopped

  node-api:
    build: ./Node
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/afl_fantasy
      - REDIS_URL=redis://redis:6379
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
      python-api:
        condition: service_started
    volumes:
      - ./Shared/.env:/app/.env
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - python-api
      - node-api
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

#### Nginx Configuration
Create `nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream python_backend {
        server python-api:5000;
    }
    
    upstream node_backend {
        server node-api:3000;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        # Python API routes
        location /api/trade_score {
            proxy_pass http://python_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /health {
            proxy_pass http://python_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Node.js API routes (default)
        location / {
            proxy_pass http://node_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        # WebSocket support
        location /ws {
            proxy_pass http://node_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
        }
    }
}
```

#### Deploy with Docker
```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Scale services
docker-compose up -d --scale node-api=3
```

## Cloud Deployment Options

### AWS Deployment

#### Using AWS ECS with Fargate
```bash
# Install AWS CLI and ECS CLI
pip install awscli
curl -Lo ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-darwin-amd64-latest
chmod +x ecs-cli && mv ecs-cli /usr/local/bin/

# Configure ECS CLI
ecs-cli configure --cluster afl-fantasy --default-launch-type FARGATE --region us-west-2

# Create cluster
ecs-cli up --cluster-config afl-fantasy --ecs-profile default

# Create task definition and deploy
ecs-cli compose --file docker-compose.yml up
```

#### Using AWS Lambda (Serverless)
For the Python API, you can deploy as a Lambda function:

```bash
# Install Zappa
pip install zappa

# Initialize Zappa
zappa init

# Deploy
zappa deploy dev
```

### Google Cloud Deployment

#### Using Cloud Run
```bash
# Build and push Python service
cd Python
gcloud builds submit --tag gcr.io/PROJECT_ID/afl-python-api
gcloud run deploy afl-python-api --image gcr.io/PROJECT_ID/afl-python-api --port 5000

# Build and push Node service
cd Node
gcloud builds submit --tag gcr.io/PROJECT_ID/afl-node-api
gcloud run deploy afl-node-api --image gcr.io/PROJECT_ID/afl-node-api --port 3000
```

### Digital Ocean Deployment

#### Using App Platform
```yaml
# .do/app.yaml
name: afl-fantasy-backend
services:
- name: python-api
  source_dir: /ios/Backend/Python
  environment_slug: python
  instance_count: 1
  instance_size_slug: basic-xxs
  http_port: 5000
  routes:
  - path: /api/trade_score
  - path: /health

- name: node-api
  source_dir: /ios/Backend/Node
  environment_slug: node-js
  instance_count: 1
  instance_size_slug: basic-xxs
  http_port: 3000
  routes:
  - path: /

databases:
- name: postgres
  engine: PG
  version: "15"
  
- name: redis
  engine: REDIS
  version: "7"
```

## SSL/TLS Configuration

### Let's Encrypt (Free SSL)
```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Generate certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Self-signed Certificate (Development)
```bash
# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/private.key -out ssl/certificate.crt
```

## Monitoring & Logging

### Health Checks
Create monitoring scripts:

```bash
#!/bin/bash
# health-check.sh

check_service() {
    local service_name=$1
    local url=$2
    
    if curl -sf "$url" > /dev/null; then
        echo "✅ $service_name is healthy"
        return 0
    else
        echo "❌ $service_name is down"
        return 1
    fi
}

check_service "Python API" "http://localhost:5000/health"
check_service "Node API" "http://localhost:3000/api/health"
```

### Log Management
```bash
# Centralized logging with rsyslog
sudo apt-get install rsyslog

# Configure log rotation
sudo nano /etc/logrotate.d/afl-fantasy

# Add log shipping to external service (optional)
# - ELK Stack
# - Splunk
# - CloudWatch
# - DataDog
```

## Backup Strategy

### Database Backups
```bash
#!/bin/bash
# backup-database.sh

BACKUP_DIR="/backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# PostgreSQL backup
pg_dump afl_fantasy | gzip > "$BACKUP_DIR/afl_fantasy_$(date +%H%M).sql.gz"

# Redis backup (if using persistence)
redis-cli BGSAVE
cp /var/lib/redis/dump.rdb "$BACKUP_DIR/"

# Upload to cloud storage (S3, GCS, etc.)
aws s3 sync "$BACKUP_DIR" s3://your-backup-bucket/$(date +%Y-%m-%d)/
```

### Application Backups
```bash
# Backup application configuration
tar -czf "app-config-$(date +%Y%m%d).tar.gz" \
  ios/Backend/Shared/.env \
  ios/Backend/Node/ecosystem.config.js \
  ios/Backend/Python/gunicorn.conf.py \
  docker-compose.yml \
  nginx.conf
```

## Performance Optimization

### Python Optimizations
```bash
# Install performance monitoring
pip install newrelic

# Use faster JSON library
pip install orjson

# Enable JIT compilation
pip install PyPy3  # Alternative Python implementation
```

### Node.js Optimizations
```bash
# Install performance monitoring
pnpm add @newrelic/native-metrics

# Use faster libraries
pnpm add ioredis  # Faster Redis client
pnpm add compression  # Response compression
```

### Database Optimization
```sql
-- Add indexes for common queries
CREATE INDEX idx_players_position ON players(position);
CREATE INDEX idx_players_team ON players(team);
CREATE INDEX idx_players_price ON players(price);

-- Enable query statistics
ALTER SYSTEM SET track_activity_query_size = 2048;
ALTER SYSTEM SET pg_stat_statements.track = 'all';
```

## Scaling Considerations

### Horizontal Scaling
```bash
# Load balancer configuration (HAProxy example)
cat > haproxy.cfg << 'EOF'
frontend afl_frontend
    bind *:80
    default_backend afl_backend

backend afl_backend
    balance roundrobin
    server api1 server1:3000 check
    server api2 server2:3000 check
    server api3 server3:3000 check
EOF
```

### Database Scaling
```bash
# Read replicas for PostgreSQL
# Master-slave configuration
# Connection pooling with PgBouncer
```

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Find and kill process using port
lsof -ti :3000 | xargs kill -9
lsof -ti :5000 | xargs kill -9
```

#### Database Connection Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connections
psql -c "SELECT * FROM pg_stat_activity;"

# Reset connections
sudo systemctl restart postgresql
```

#### Memory Issues
```bash
# Monitor memory usage
htop
free -h

# Adjust service memory limits
# For Node.js: --max-old-space-size=4096
# For Python: set in gunicorn workers
```

### Log Locations
- **Python logs**: `/var/log/afl-python-api/`
- **Node.js logs**: `/var/log/afl-node-api/`
- **Nginx logs**: `/var/log/nginx/`
- **PostgreSQL logs**: `/var/log/postgresql/`

## Security Checklist

- [ ] Environment variables properly secured
- [ ] Database credentials rotated regularly
- [ ] SSL/TLS certificates configured
- [ ] Firewall rules configured
- [ ] Rate limiting enabled
- [ ] Input validation implemented
- [ ] CORS properly configured
- [ ] Security headers added
- [ ] Regular security updates applied
- [ ] Monitoring and alerting configured

---

*Last updated: December 6, 2024*
