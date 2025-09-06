#!/bin/bash

# AFL Fantasy Platform - Deployment Package Generator
# Creates a complete deployment package ready for any VPS/cloud provider

set -e

PACKAGE_NAME="afl-fantasy-platform-$(date +%Y%m%d-%H%M%S)"
TEMP_DIR="/tmp/$PACKAGE_NAME"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] $1${NC}"
}

log "🚀 Generating AFL Fantasy Platform Deployment Package"

# Create temporary directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

log "📁 Copying essential deployment files..."

# Core application files
cp -r /app/client ./
cp -r /app/server ./
cp -r /app/shared ./
cp -r /app/k8s ./
cp -r /app/helm ./
cp -r /app/terraform ./
cp -r /app/scripts ./
cp -r /app/monitoring ./

# Configuration files
cp /app/package.json ./
cp /app/package-lock.json ./
cp /app/tsconfig.json ./
cp /app/vite.config.ts ./
cp /app/tailwind.config.ts ./
cp /app/postcss.config.js ./
cp /app/drizzle.config.ts ./

# Docker and deployment files
cp /app/Dockerfile ./
cp /app/docker-compose.yml ./
cp /app/nginx.conf ./
cp /app/prometheus.yml ./
cp /app/init.sql ./
cp /app/.env.example ./

# Data files
cp /app/player_data.json ./
cp /app/dvp_matrix.json ./
cp /app/*.py ./ 2>/dev/null || true

# Documentation
cp /app/README.md ./
cp /app/DOWNLOAD_AND_DEPLOY.md ./
cp /app/PRODUCTION_CHECKLIST.md ./
cp /app/ENTERPRISE_MVP_TECHNICAL_DOCS.md ./
cp /app/replit.md ./

# Essential assets (only needed ones)
mkdir -p attached_assets
cp /app/attached_assets/currentdt_liveR13_1753069161334.xlsx ./attached_assets/ 2>/dev/null || true
cp /app/attached_assets/DFS_DVP_Matchup_Tables_FIXED_1753016059835.xlsx ./attached_assets/ 2>/dev/null || true

log "🔧 Creating deployment automation..."

# Create quick deploy script
cat > quick-deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 AFL Fantasy Platform - Quick Deploy"
echo "======================================"

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting." >&2; exit 1; }

# Make deploy script executable
chmod +x scripts/deploy.sh

# Ask user for deployment type
echo "Choose deployment method:"
echo "1) Docker Compose (Local/Single Server) - Recommended for testing"
echo "2) Kubernetes (Production) - Requires existing K8s cluster"
echo "3) Helm (Enterprise) - Full enterprise deployment"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo "🐳 Deploying with Docker Compose..."
        ./scripts/deploy.sh docker
        ;;
    2)
        echo "⎈ Deploying to Kubernetes..."
        ./scripts/deploy.sh k8s
        ;;
    3)
        echo "📊 Deploying with Helm..."
        ./scripts/deploy.sh helm
        ;;
    *)
        echo "Invalid choice. Defaulting to Docker Compose..."
        ./scripts/deploy.sh docker
        ;;
esac

echo ""
echo "✅ Deployment complete!"
echo "📖 See PRODUCTION_CHECKLIST.md for verification steps"
EOF

chmod +x quick-deploy.sh

# Create README for the package
cat > DEPLOYMENT_README.md << 'EOF'
# AFL Fantasy Platform - Deployment Package

This package contains everything needed to deploy the AFL Fantasy Platform on any VPS or cloud provider.

## 🚀 Quick Start (30 seconds)

1. **Extract and Enter Directory**
   ```bash
   tar -xzf afl-fantasy-platform-*.tar.gz
   cd afl-fantasy-platform-*
   ```

2. **Run Quick Deploy**
   ```bash
   ./quick-deploy.sh
   ```

3. **Access Application**
   - Application: http://localhost:5000
   - Monitoring: http://localhost:3001

## 📋 What's Included

- **Complete Application**: All 642 AFL players, 25+ fantasy tools
- **Enterprise Infrastructure**: Docker, Kubernetes, Helm charts
- **Monitoring Stack**: Prometheus, Grafana, health checks
- **Multi-Cloud Support**: GCP, AWS, local deployment
- **Security Hardened**: HTTPS, secrets management, rate limiting
- **Auto-Scaling**: Horizontal and vertical scaling configured
- **Documentation**: Complete deployment and operational guides

## 🎯 Deployment Options

### Local Development (2 minutes)
```bash
./scripts/deploy.sh docker
```

### Kubernetes Production (5 minutes)
```bash
./scripts/deploy.sh k8s
```

### Enterprise Helm (5 minutes)
```bash
./scripts/deploy.sh helm
```

### Cloud Deployment (10 minutes)
```bash
# Google Cloud
export GOOGLE_PROJECT_ID="your-project"
./scripts/deploy.sh gcp

# AWS
export AWS_REGION="us-west-2"
./scripts/deploy.sh aws
```

## 📚 Documentation

- `DOWNLOAD_AND_DEPLOY.md` - Complete deployment guide
- `PRODUCTION_CHECKLIST.md` - Production readiness checklist
- `ENTERPRISE_MVP_TECHNICAL_DOCS.md` - Technical architecture
- `replit.md` - Project overview and recent changes

## ✅ Verification

After deployment, verify everything works:

```bash
# Health check
curl http://localhost:5000/api/health

# Player data (should return 642 players)
curl http://localhost:5000/api/stats/combined-stats | jq 'length'

# Frontend verification
open http://localhost:5000
```

## 🎉 Success Metrics

Your deployment is successful when:
- ✅ Application responds at http://localhost:5000
- ✅ All 642 players display in stats page
- ✅ Dashboard, lineup, and tools pages work
- ✅ Response times < 200ms
- ✅ Auto-scaling functional (K8s/Helm)
- ✅ Monitoring dashboards accessible

## 🆘 Support

- **Documentation**: Complete guides in `/docs` directory
- **Health Monitoring**: `/api/health` endpoint
- **Logs**: Check `docker-compose logs` or `kubectl logs`
- **Issues**: Review PRODUCTION_CHECKLIST.md troubleshooting section

---

**Ready for Enterprise Use** 🚀
Complete AFL Fantasy platform with 642 players, 25+ tools, and enterprise-grade infrastructure.
EOF

log "📦 Creating deployment package..."

# Create the package
cd /tmp
tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"

# Move to accessible location
mv "$PACKAGE_NAME.tar.gz" /app/
rm -rf "$TEMP_DIR"

log "✅ Deployment package created: $PACKAGE_NAME.tar.gz"
log ""
log "📋 Package Contents:"
log "   • Complete application with 642 players"
log "   • Docker, Kubernetes, Helm configurations"
log "   • Monitoring and security setup"
log "   • Multi-cloud deployment scripts"
log "   • Comprehensive documentation"
log ""
log "🚀 Ready for deployment on any VPS or cloud provider!"
log "   Download: /app/$PACKAGE_NAME.tar.gz"
log "   Size: $(du -h /app/$PACKAGE_NAME.tar.gz | cut -f1)"

echo "/app/$PACKAGE_NAME.tar.gz"