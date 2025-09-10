# 🚀 AFL Fantasy Platform - Download & Deploy Guide

Complete deployment instructions for enterprise VPS, cloud, and local environments.

## 📥 Download Options

### Option 1: Fork from GitHub (Recommended)
```bash
# Fork the repository on GitHub, then:
git clone https://github.com/yourusername/afl-fantasy-platform.git
cd afl-fantasy-platform
```

### Option 2: Download ZIP from Replit
1. Click "Download as ZIP" from Replit
2. Extract to your desired location
3. Open terminal in extracted folder

## ⚡ Quick Deploy (30 seconds)

For immediate deployment with all defaults:

```bash
./quick-deploy.sh
```

**Access your platform**: http://localhost:5000

## 🐳 Docker Compose Deployment (Recommended)

Perfect for local development, testing, and single-server production.

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum
- 10GB disk space

### Deployment Steps

```bash
# 1. Prepare environment
cp .env.example .env

# 2. Deploy all services
docker-compose up -d

# 3. Verify deployment
curl http://localhost:5000/api/health
```

### Services Included
- **Application**: AFL Fantasy Platform (port 5000)
- **Database**: PostgreSQL 14 (port 5432)
- **Cache**: Redis 7 (port 6379)
- **Monitoring**: Prometheus (port 9090)
- **Dashboards**: Grafana (port 3001, admin/admin)
- **Load Balancer**: Nginx (port 80, 443)

### Verification
```bash
# Health check
curl http://localhost:5000/api/health
# Expected: {"status":"healthy","database":"connected"}

# Player count
curl http://localhost:5000/api/stats/combined-stats | jq 'length'
# Expected: 642

# Performance check
time curl -s http://localhost:5000/api/stats/combined-stats > /dev/null
# Expected: < 200ms
```

## ⎈ Kubernetes Deployment (Production)

For production environments requiring high availability and auto-scaling.

### Prerequisites
- Kubernetes cluster 1.24+
- kubectl configured
- 8GB RAM minimum per node
- LoadBalancer or Ingress support

### Quick Deployment
```bash
# Apply all manifests
kubectl apply -f k8s/

# Verify deployment
kubectl get pods -n afl-fantasy
kubectl port-forward svc/afl-fantasy-service 5000:5000 -n afl-fantasy
```

### Advanced Configuration
```bash
# Custom namespace
kubectl create namespace my-fantasy-platform
kubectl apply -f k8s/ -n my-fantasy-platform

# Scale replicas
kubectl scale deployment afl-fantasy-app --replicas=5 -n afl-fantasy

# Rolling update
kubectl set image deployment/afl-fantasy-app app=ghcr.io/yourusername/afl-fantasy-platform:latest -n afl-fantasy
```

### Production Features
- **Auto-scaling**: 3-10 replicas based on CPU/memory
- **Health checks**: Liveness and readiness probes
- **Resource limits**: CPU and memory constraints
- **Persistent storage**: PostgreSQL data persistence
- **Service mesh**: Ready for Istio integration

## 📊 Helm Deployment (Enterprise)

Full enterprise deployment with comprehensive monitoring and observability.

### Prerequisites
- Helm 3.x installed
- Kubernetes cluster
- Persistent volume support

### Installation
```bash
# Add AFL Fantasy Helm repository
helm repo add afl-fantasy ./helm
helm repo update

# Install with default values
helm install afl-fantasy-platform afl-fantasy/afl-fantasy-platform -n afl-fantasy --create-namespace

# Install with custom values
helm install afl-fantasy-platform afl-fantasy/afl-fantasy-platform -n afl-fantasy --create-namespace -f custom-values.yaml
```

### Monitoring Stack
```bash
# Install Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Access Grafana
kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring
# Username: admin, Password: prom-operator
```

### Enterprise Features
- **TLS termination**: Automatic HTTPS with cert-manager
- **Secret management**: Encrypted secrets storage
- **Backup automation**: PostgreSQL backup to cloud storage
- **Multi-environment**: Dev, staging, production configs
- **Compliance**: Security policies and network policies

## ☁️ Cloud Deployment

### Google Cloud Platform (GCP)
```bash
# Set up GCP project
export GOOGLE_PROJECT_ID="your-project-id"
gcloud config set project $GOOGLE_PROJECT_ID

# Create GKE cluster
gcloud container clusters create afl-fantasy-cluster \
  --num-nodes=3 \
  --machine-type=e2-standard-2 \
  --zone=us-central1-a

# Deploy application
kubectl apply -f k8s/
```

### Amazon Web Services (AWS)
```bash
# Set up AWS credentials
export AWS_REGION="us-west-2"
aws configure

# Create EKS cluster (using eksctl)
eksctl create cluster --name afl-fantasy --region $AWS_REGION --nodes 3

# Deploy application
kubectl apply -f k8s/
```

### Azure Container Instances (ACI)
```bash
# Create resource group
az group create --name afl-fantasy-rg --location eastus

# Create AKS cluster
az aks create --resource-group afl-fantasy-rg --name afl-fantasy-cluster --node-count 3

# Deploy application
kubectl apply -f k8s/
```

## 🔧 Configuration

### Environment Variables

#### Basic Configuration
```bash
# Application
NODE_ENV=production
PORT=5000
DATABASE_URL=postgresql://postgres:password@localhost:5432/afl_fantasy

# Security
SESSION_SECRET=your-secure-session-secret
CORS_ORIGIN=https://your-domain.com
```

#### Optional API Keys
```bash
# AFL Fantasy (for real user data)
AFL_FANTASY_USERNAME=your_username
AFL_FANTASY_PASSWORD=your_password

# DFS Australia (enhanced statistics)
DFS_AUSTRALIA_API_KEY=your_api_key

# OpenAI (AI-powered analysis)
OPENAI_API_KEY=your_openai_key

# Champion Data (advanced analytics)
CHAMPION_DATA_API_KEY=your_champion_data_key
```

#### Monitoring & Observability
```bash
# Monitoring
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true
HEALTH_CHECK_PATH=/api/health

# Logging
LOG_LEVEL=info
LOG_FORMAT=json
ENABLE_REQUEST_LOGGING=true
```

### Custom Configuration Files

#### Docker Compose Override
Create `docker-compose.override.yml`:
```yaml
version: '3.8'
services:
  afl-fantasy-app:
    environment:
      - NODE_ENV=production
      - CUSTOM_SETTING=your_value
    volumes:
      - ./custom-data:/app/data
```

#### Kubernetes ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: afl-fantasy-config
  namespace: afl-fantasy
data:
  NODE_ENV: "production"
  LOG_LEVEL: "info"
  CUSTOM_SETTING: "your_value"
```

## 🏭 Production Deployment

### Security Checklist
- [ ] **HTTPS enabled**: TLS certificates configured
- [ ] **Secrets management**: All sensitive data encrypted
- [ ] **Network security**: Firewall rules and network policies
- [ ] **Container security**: Images scanned for vulnerabilities
- [ ] **Access control**: RBAC and authentication configured
- [ ] **Data encryption**: Database encryption at rest and in transit

### Performance Optimization
- [ ] **Resource limits**: CPU and memory limits set
- [ ] **Horizontal scaling**: Auto-scaling policies configured
- [ ] **Caching**: Redis caching enabled and optimized
- [ ] **Database tuning**: PostgreSQL performance optimized
- [ ] **CDN**: Static assets served via CDN
- [ ] **Compression**: Gzip compression enabled

### Monitoring & Alerting
- [ ] **Health checks**: Application and database health monitoring
- [ ] **Metrics collection**: Prometheus metrics configured
- [ ] **Log aggregation**: Centralized logging implemented
- [ ] **Alert rules**: Critical alerts configured
- [ ] **Dashboard setup**: Grafana dashboards deployed
- [ ] **Uptime monitoring**: External uptime monitoring enabled

### Backup & Recovery
- [ ] **Database backups**: Automated PostgreSQL backups
- [ ] **Application data**: User data backup procedures
- [ ] **Disaster recovery**: Recovery procedures documented
- [ ] **Backup testing**: Regular restore testing performed
- [ ] **Retention policies**: Backup retention policies defined

## 🔍 Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Find process using port 5000
lsof -i :5000
kill -9 <PID>

# Or use different port
export PORT=5001
docker-compose up -d
```

#### Docker Issues
```bash
# Clean Docker system
docker system prune -af
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

#### Database Connection
```bash
# Check PostgreSQL status
docker-compose logs postgres

# Test connection
docker-compose exec postgres psql -U postgres -d afl_fantasy -c "SELECT 1;"

# Reset database
docker-compose down -v
docker-compose up -d postgres
```

#### Application Not Starting
```bash
# Check application logs
docker-compose logs afl-fantasy-app

# Verify environment variables
docker-compose exec afl-fantasy-app env | grep -E "(NODE_ENV|DATABASE_URL)"

# Restart application only
docker-compose restart afl-fantasy-app
```

#### Performance Issues
```bash
# Check resource usage
docker stats

# Monitor database performance
docker-compose exec postgres psql -U postgres -d afl_fantasy -c "SELECT * FROM pg_stat_activity;"

# Clear application cache
curl -X POST http://localhost:5000/api/cache/clear
```

### Kubernetes Troubleshooting

#### Pod Issues
```bash
# Check pod status
kubectl get pods -n afl-fantasy

# View pod logs
kubectl logs -f deployment/afl-fantasy-app -n afl-fantasy

# Describe pod for events
kubectl describe pod <pod-name> -n afl-fantasy

# Execute into pod
kubectl exec -it <pod-name> -n afl-fantasy -- /bin/bash
```

#### Service Issues
```bash
# Check service endpoints
kubectl get endpoints -n afl-fantasy

# Test service connectivity
kubectl run test-pod --image=curlimages/curl -it --rm -- curl http://afl-fantasy-service:5000/api/health

# Port forward for testing
kubectl port-forward svc/afl-fantasy-service 5000:5000 -n afl-fantasy
```

#### Scaling Issues
```bash
# Check HPA status
kubectl get hpa -n afl-fantasy

# View scaling events
kubectl describe hpa afl-fantasy-hpa -n afl-fantasy

# Manual scaling
kubectl scale deployment afl-fantasy-app --replicas=5 -n afl-fantasy
```

## 📊 Performance Verification

### Load Testing
```bash
# Simple load test with curl
for i in {1..100}; do
  curl -s http://localhost:5000/api/health > /dev/null &
done
wait

# Advanced load testing with Apache Bench
ab -n 1000 -c 10 http://localhost:5000/api/stats/combined-stats

# Load testing with wrk
wrk -t12 -c400 -d30s http://localhost:5000/api/health
```

### Performance Targets
- **Response Time**: < 200ms for API endpoints
- **Throughput**: 1000+ requests per second
- **Concurrent Users**: 500+ simultaneous users
- **Memory Usage**: < 512MB per container
- **CPU Usage**: < 50% under normal load
- **Database**: < 100ms query response time

### Monitoring Commands
```bash
# Application metrics
curl http://localhost:5000/metrics

# Database performance
docker-compose exec postgres psql -U postgres -d afl_fantasy -c "
  SELECT query, mean_exec_time, calls 
  FROM pg_stat_statements 
  ORDER BY mean_exec_time DESC 
  LIMIT 10;"

# System resources
docker stats --no-stream
```

## 🎯 Success Criteria

Your deployment is successful when:

✅ **Application Health**: http://localhost:5000/api/health returns healthy  
✅ **Player Data**: All 642 players accessible via API  
✅ **Frontend Loading**: Dashboard loads without errors  
✅ **Fantasy Tools**: All 25+ tools functional  
✅ **Search & Filter**: Player search and filtering works  
✅ **Performance**: Response times under 200ms  
✅ **Monitoring**: Grafana dashboards accessible  
✅ **Database**: PostgreSQL connection stable  

## 📞 Support

### Self-Service Resources
- **[Production Checklist](./PRODUCTION_CHECKLIST.md)**: Complete deployment verification
- **[API Documentation](./docs/api.md)**: Complete API reference
- **[Architecture Guide](./AFL_Fantasy_Platform_Documentation/PROJECT_ARCHITECTURE.md)**: System design details
- **[Known Issues](./AFL_Fantasy_Platform_Documentation/KNOWN_ISSUES.md)**: Common problems and solutions

### Community Support
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and community help
- **Documentation**: Comprehensive guides in `/docs` directory

### Enterprise Support
- **Professional Services**: Available for large deployments
- **Custom Integration**: Tailored solutions for specific needs
- **24/7 Support**: Production support packages available
- **Training**: Team training and best practices workshops

---

## 🎉 Ready to Deploy!

Your AFL Fantasy Intelligence Platform includes:

- **Complete Player Database**: 642 authentic AFL players
- **Advanced Analytics**: Score projections and price predictions
- **25+ Fantasy Tools**: Captain selection, trade optimization, cash generation
- **Enterprise Infrastructure**: Docker, Kubernetes, monitoring, security
- **Production Ready**: Load balancing, auto-scaling, health checks

**Choose your deployment method and get started!**

```bash
./quick-deploy.sh
```

🏆 **Dominate your fantasy league with professional-grade analytics!**