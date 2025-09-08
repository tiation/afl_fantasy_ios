#!/bin/bash
set -euo pipefail

echo "🏗 Setting up AFL Fantasy Platform Docker environment..."

# Create required directories
echo "📁 Creating required directories..."
mkdir -p \
    backend/python/data \
    backend/python/logs \
    scrapers/data \
    scrapers/logs \
    data \
    logs \
    monitoring/grafana/dashboards \
    monitoring/grafana/datasources \
    backups

# Create placeholder directories if they don't exist
[ ! -d "backend/python/api" ] && mkdir -p backend/python/api
[ ! -d "backend/python/scrapers" ] && mkdir -p backend/python/scrapers
[ ! -d "scrapers" ] && mkdir -p scrapers

# Copy necessary files
echo "📋 Copying configuration files..."
cp -n .env.example .env 2>/dev/null || true

# Set permissions
echo "🔒 Setting permissions..."
chmod -R 755 \
    backend/python/data \
    backend/python/logs \
    scrapers/data \
    scrapers/logs \
    data \
    logs \
    monitoring \
    backups

# Make this script executable
chmod +x scripts/setup-docker.sh

echo "✅ Setup complete! You can now run: docker compose -f docker-compose.unified.yml up"
