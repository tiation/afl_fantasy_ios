#!/bin/bash

# Enterprise AFL Fantasy Platform Deployment Script
# Supports Docker, Kubernetes, GCP, AWS, and local deployments

set -e

# Configuration
NAMESPACE="afl-fantasy"
APP_NAME="afl-fantasy-platform"
VERSION=${VERSION:-"latest"}
ENVIRONMENT=${ENVIRONMENT:-"production"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    # Check kubectl for Kubernetes deployments
    if [[ "$1" == "k8s" ]] && ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed"
    fi
    
    # Check Helm for Helm deployments
    if [[ "$1" == "helm" ]] && ! command -v helm &> /dev/null; then
        error "Helm is not installed"
    fi
    
    # Check Terraform for cloud deployments
    if [[ "$1" == "terraform" ]] && ! command -v terraform &> /dev/null; then
        error "Terraform is not installed"
    fi
    
    log "Prerequisites check passed"
}

# Build Docker image
build_image() {
    log "Building Docker image..."
    
    docker build \
        --target production \
        --tag "${APP_NAME}:${VERSION}" \
        --tag "${APP_NAME}:latest" \
        .
    
    log "Docker image built successfully"
}

# Deploy with Docker Compose
deploy_docker() {
    log "Starting Docker Compose deployment..."
    
    # Build and start services
    docker-compose down -v
    docker-compose up -d --build
    
    # Wait for services to be ready
    log "Waiting for services to be ready..."
    sleep 30
    
    # Health check
    if curl -f http://localhost:5000/api/health > /dev/null 2>&1; then
        log "✅ Docker deployment successful!"
        log "Application available at: http://localhost:5000"
        log "Grafana dashboard at: http://localhost:3001"
        log "Prometheus at: http://localhost:9090"
    else
        error "Docker deployment failed - health check failed"
    fi
}

# Deploy to Kubernetes
deploy_k8s() {
    log "Starting Kubernetes deployment..."
    
    build_image
    
    # Create namespace
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Apply configurations
    kubectl apply -f k8s/ -n $NAMESPACE
    
    # Wait for deployment
    kubectl wait --for=condition=available --timeout=300s deployment/afl-fantasy-app -n $NAMESPACE
    
    log "✅ Kubernetes deployment successful!"
    log "Check status: kubectl get pods -n $NAMESPACE"
    log "Port forward: kubectl port-forward svc/afl-fantasy-service 5000:5000 -n $NAMESPACE"
}

# Deploy with Helm
deploy_helm() {
    log "Starting Helm deployment..."
    
    build_image
    
    # Add Helm repositories if needed
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    
    # Create namespace
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Install/upgrade with Helm
    helm upgrade --install $APP_NAME ./helm \
        --namespace $NAMESPACE \
        --set image.tag=$VERSION \
        --set environment=$ENVIRONMENT \
        --wait --timeout=10m
    
    log "✅ Helm deployment successful!"
    log "Check status: helm status $APP_NAME -n $NAMESPACE"
}

# Deploy monitoring stack
deploy_monitoring() {
    log "Deploying monitoring stack..."
    
    # Add Prometheus community Helm repo
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Deploy Prometheus and Grafana
    helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=admin123 \
        --wait
    
    log "✅ Monitoring stack deployed!"
    log "Access Grafana: kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring"
}
    log "Deploying with Docker Compose..."
    
    # Build image first
    build_image
    
    # Start services
    docker-compose up -d --build
    
    # Wait for services to be ready
    log "Waiting for services to be ready..."
    sleep 30
    
    # Health check
    if curl -f http://localhost:5000/api/health > /dev/null 2>&1; then
        log "✅ Application deployed successfully with Docker Compose"
        log "🌐 Access the application at: http://localhost:5000"
    else
        error "Health check failed"
    fi
}

# Deploy to Kubernetes
deploy_k8s() {
    log "Deploying to Kubernetes..."
    
    # Create namespace
    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
    
    # Apply all Kubernetes manifests
    kubectl apply -f k8s/ -n ${NAMESPACE}
    
    # Wait for deployment
    kubectl rollout status deployment/afl-fantasy-app -n ${NAMESPACE} --timeout=300s
    
    # Get service URL
    SERVICE_URL=$(kubectl get svc afl-fantasy-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    if [[ -n "$SERVICE_URL" ]]; then
        log "✅ Application deployed successfully to Kubernetes"
        log "🌐 Access the application at: http://${SERVICE_URL}:5000"
    else
        log "✅ Application deployed to Kubernetes"
        log "📝 Run 'kubectl port-forward svc/afl-fantasy-service 5000:5000 -n ${NAMESPACE}' to access locally"
    fi
}

# Deploy with Helm
deploy_helm() {
    log "Deploying with Helm..."
    
    # Add required repositories
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    # Install/upgrade the release
    helm upgrade --install ${APP_NAME} ./helm \
        --namespace ${NAMESPACE} \
        --create-namespace \
        --set image.tag=${VERSION} \
        --set environment=${ENVIRONMENT} \
        --wait --timeout=10m
    
    log "✅ Application deployed successfully with Helm"
    
    # Get ingress info
    INGRESS_IP=$(kubectl get ingress ${APP_NAME}-ingress -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [[ -n "$INGRESS_IP" ]]; then
        log "🌐 Access the application at: http://${INGRESS_IP}"
    else
        log "📝 Run 'kubectl port-forward svc/${APP_NAME} 5000:5000 -n ${NAMESPACE}' to access locally"
    fi
}

# Deploy to GCP
deploy_gcp() {
    log "Deploying to Google Cloud Platform..."
    
    if [[ -z "$GOOGLE_PROJECT_ID" ]]; then
        error "GOOGLE_PROJECT_ID environment variable is required"
    fi
    
    # Initialize Terraform
    cd terraform
    terraform init
    
    # Plan deployment
    terraform plan \
        -var="cloud_provider=gcp" \
        -var="project_id=${GOOGLE_PROJECT_ID}" \
        -var="region=${GCP_REGION:-us-central1}" \
        -var="environment=${ENVIRONMENT}"
    
    # Apply deployment
    terraform apply -auto-approve \
        -var="cloud_provider=gcp" \
        -var="project_id=${GOOGLE_PROJECT_ID}" \
        -var="region=${GCP_REGION:-us-central1}" \
        -var="environment=${ENVIRONMENT}"
    
    cd ..
    
    # Configure kubectl
    gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
        --region ${GCP_REGION:-us-central1} \
        --project ${GOOGLE_PROJECT_ID}
    
    # Deploy application
    deploy_helm
    
    log "✅ Application deployed successfully to GCP"
}

# Deploy to AWS
deploy_aws() {
    log "Deploying to Amazon Web Services..."
    
    if [[ -z "$AWS_REGION" ]]; then
        export AWS_REGION="us-west-2"
    fi
    
    # Initialize Terraform
    cd terraform
    terraform init
    
    # Plan deployment
    terraform plan \
        -var="cloud_provider=aws" \
        -var="region=${AWS_REGION}" \
        -var="environment=${ENVIRONMENT}"
    
    # Apply deployment
    terraform apply -auto-approve \
        -var="cloud_provider=aws" \
        -var="region=${AWS_REGION}" \
        -var="environment=${ENVIRONMENT}"
    
    cd ..
    
    # Configure kubectl
    aws eks update-kubeconfig \
        --region ${AWS_REGION} \
        --name $(terraform output -raw cluster_name)
    
    # Deploy application
    deploy_helm
    
    log "✅ Application deployed successfully to AWS"
}

# Monitoring setup
setup_monitoring() {
    log "Setting up monitoring..."
    
    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Add Prometheus and Grafana
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Install Prometheus
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --wait
    
    log "✅ Monitoring setup complete"
    log "📊 Access Grafana: kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
    log "📈 Access Prometheus: kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring"
}

# Main deployment logic
main() {
    local deployment_type=${1:-"docker"}
    
    case $deployment_type in
        docker)
            check_prerequisites docker
            deploy_docker
            ;;
        k8s)
            check_prerequisites k8s
            build_image
            deploy_k8s
            ;;
        helm)
            check_prerequisites helm
            build_image
            deploy_helm
            ;;
        gcp)
            check_prerequisites terraform
            build_image
            deploy_gcp
            ;;
        aws)
            check_prerequisites terraform
            build_image
            deploy_aws
            ;;
        monitoring)
            check_prerequisites helm
            setup_monitoring
            ;;
        *)
            echo "Usage: $0 {docker|k8s|helm|gcp|aws|monitoring}"
            echo ""
            echo "Deployment options:"
            echo "  docker     - Deploy with Docker Compose (local development)"
            echo "  k8s        - Deploy to existing Kubernetes cluster"
            echo "  helm       - Deploy to Kubernetes using Helm charts"
            echo "  gcp        - Deploy to Google Cloud Platform"
            echo "  aws        - Deploy to Amazon Web Services"
            echo "  monitoring - Setup monitoring stack (Prometheus + Grafana)"
            echo ""
            echo "Environment variables:"
            echo "  VERSION           - Image version (default: latest)"
            echo "  ENVIRONMENT       - Environment name (default: production)"
            echo "  GOOGLE_PROJECT_ID - GCP project ID (required for GCP)"
            echo "  GCP_REGION        - GCP region (default: us-central1)"
            echo "  AWS_REGION        - AWS region (default: us-west-2)"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"