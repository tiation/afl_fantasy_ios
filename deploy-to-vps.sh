#!/bin/bash

# AFL Fantasy Manager VPS Deployment Script
# Deploys to docker.sxc.codes (145.223.22.7)

set -e

# Configuration
VPS_HOST="145.223.22.7"
VPS_USER="root"
SSH_KEY="/Users/tiaastor/.ssh/hostinger_key"
DEPLOY_DIR="/opt/afl-fantasy"
APP_NAME="afl-fantasy-manager"

echo "🚀 Starting deployment to docker.sxc.codes..."

# Create deployment directory on VPS
echo "📁 Creating deployment directory..."
ssh -i "$SSH_KEY" "$VPS_USER@$VPS_HOST" "mkdir -p $DEPLOY_DIR && cd $DEPLOY_DIR"

# Create production docker-compose file
echo "📝 Creating production docker-compose configuration..."
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  afl-fantasy-app:
    image: node:18-alpine
    working_dir: /app
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/afl_fantasy
      - PORT=5000
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      - ./:/app
      - /app/node_modules
    networks:
      - afl-network
    restart: unless-stopped
    command: sh -c "npm ci --only=production && npm start"

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=afl_fantasy
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    ports:
      - "5432:5432"
    networks:
      - afl-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d afl_fantasy"]
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - afl-fantasy-app
    networks:
      - afl-network
    restart: unless-stopped

volumes:
  postgres_data:

networks:
  afl-network:
    driver: bridge
EOF

# Build the application locally
echo "🔨 Building application..."
npm run build

# Create deployment package
echo "📦 Creating deployment package..."
tar -czf afl-fantasy-deploy.tar.gz \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='__pycache__' \
  --exclude='.pytest_cache' \
  --exclude='venv' \
  --exclude='.venv' \
  --exclude='*.log' \
  package.json \
  package-lock.json \
  requirements.txt \
  dist/ \
  init.sql \
  nginx.conf \
  prometheus.yml \
  docker-compose.prod.yml

# Transfer files to VPS
echo "📤 Transferring files to VPS..."
scp -i "$SSH_KEY" afl-fantasy-deploy.tar.gz "$VPS_USER@$VPS_HOST:$DEPLOY_DIR/"

# Deploy on VPS
echo "🚢 Deploying on VPS..."
ssh -i "$SSH_KEY" "$VPS_USER@$VPS_HOST" << EOF
cd $DEPLOY_DIR
echo "Extracting deployment package..."
tar -xzf afl-fantasy-deploy.tar.gz

echo "Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down || true

echo "Cleaning up old containers and images..."
docker system prune -f

echo "Starting new deployment..."
docker-compose -f docker-compose.prod.yml up -d

echo "Waiting for services to start..."
sleep 30

echo "Testing application health..."
if curl -f http://localhost:5000/api/health > /dev/null 2>&1; then
    echo "✅ Application is healthy and running!"
    echo "🌐 Access your application at: http://145.223.22.7:5000"
else
    echo "❌ Health check failed. Checking logs..."
    docker-compose -f docker-compose.prod.yml logs afl-fantasy-app
    exit 1
fi

echo "🎉 Deployment completed successfully!"
EOF

# Cleanup local files
rm -f afl-fantasy-deploy.tar.gz docker-compose.prod.yml

echo "✅ Deployment script completed!"
echo "📱 Monitor your application at: http://145.223.22.7:5000"
echo "🔍 Check logs: ssh -i $SSH_KEY $VPS_USER@$VPS_HOST 'cd $DEPLOY_DIR && docker-compose -f docker-compose.prod.yml logs -f'"
