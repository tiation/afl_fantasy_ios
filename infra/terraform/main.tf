# Terraform Configuration for Enterprise AFL Fantasy Platform
# Supports GCP, AWS, and Azure deployments

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Variables
variable "cloud_provider" {
  description = "Cloud provider to deploy to"
  type        = string
  default     = "gcp"
  validation {
    condition     = contains(["gcp", "aws", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be one of: gcp, aws, azure."
  }
}

variable "project_id" {
  description = "Project ID for GCP or equivalent"
  type        = string
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "afl-fantasy-cluster"
}

# Local values
locals {
  common_labels = {
    project     = "afl-fantasy-platform"
    environment = var.environment
    managed-by  = "terraform"
  }
}

# GCP Configuration
resource "google_container_cluster" "primary" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  name     = var.cluster_name
  location = var.region
  
  remove_default_node_pool = true
  initial_node_count       = 1
  
  network    = google_compute_network.vpc[0].name
  subnetwork = google_compute_subnetwork.subnet[0].name
  
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }
  
  network_policy {
    enabled = true
  }
  
  ip_allocation_policy {}
  
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  count      = var.cloud_provider == "gcp" ? 1 : 0
  name       = "${var.cluster_name}-nodes"
  location   = var.region
  cluster    = google_container_cluster.primary[0].name
  node_count = 2
  
  autoscaling {
    min_node_count = 2
    max_node_count = 10
  }
  
  node_config {
    preemptible  = false
    machine_type = "e2-standard-4"
    
    service_account = google_service_account.default[0].email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    labels = local.common_labels
    
    tags = ["afl-fantasy", "gke-node"]
    
    disk_size_gb = 100
    disk_type    = "pd-ssd"
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

# VPC Network
resource "google_compute_network" "vpc" {
  count                   = var.cloud_provider == "gcp" ? 1 : 0
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count         = var.cloud_provider == "gcp" ? 1 : 0
  name          = "${var.cluster_name}-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc[0].id
  
  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }
  
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }
}

# Service Account
resource "google_service_account" "default" {
  count        = var.cloud_provider == "gcp" ? 1 : 0
  account_id   = "${var.cluster_name}-sa"
  display_name = "AFL Fantasy Service Account"
}

# Database
resource "google_sql_database_instance" "main" {
  count            = var.cloud_provider == "gcp" ? 1 : 0
  name             = "${var.cluster_name}-db"
  database_version = "POSTGRES_14"
  region           = var.region
  
  settings {
    tier = "db-f1-micro"
    
    backup_configuration {
      enabled                        = true
      start_time                     = "23:00"
      location                       = var.region
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc[0].id
    }
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
  }
  
  deletion_protection = true
}

resource "google_sql_database" "database" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  name     = "afl_fantasy"
  instance = google_sql_database_instance.main[0].name
}

# AWS Configuration (Alternative)
resource "aws_eks_cluster" "cluster" {
  count    = var.cloud_provider == "aws" ? 1 : 0
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster[0].arn
  
  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_node_group" "nodes" {
  count           = var.cloud_provider == "aws" ? 1 : 0
  cluster_name    = aws_eks_cluster.cluster[0].name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.nodes[0].arn
  subnet_ids      = aws_subnet.private[*].id
  
  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 2
  }
  
  instance_types = ["t3.medium"]
  
  depends_on = [
    aws_iam_role_policy_attachment.nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = var.cloud_provider == "gcp" ? "https://${google_container_cluster.primary[0].endpoint}" : "https://${aws_eks_cluster.cluster[0].endpoint}"
  token                  = var.cloud_provider == "gcp" ? data.google_client_config.default.access_token : data.aws_eks_cluster_auth.cluster[0].token
  cluster_ca_certificate = var.cloud_provider == "gcp" ? base64decode(google_container_cluster.primary[0].master_auth.0.cluster_ca_certificate) : base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data)
}

provider "helm" {
  kubernetes {
    host                   = var.cloud_provider == "gcp" ? "https://${google_container_cluster.primary[0].endpoint}" : "https://${aws_eks_cluster.cluster[0].endpoint}"
    token                  = var.cloud_provider == "gcp" ? data.google_client_config.default.access_token : data.aws_eks_cluster_auth.cluster[0].token
    cluster_ca_certificate = var.cloud_provider == "gcp" ? base64decode(google_container_cluster.primary[0].master_auth.0.cluster_ca_certificate) : base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data)
  }
}

# Data sources
data "google_client_config" "default" {
  count = var.cloud_provider == "gcp" ? 1 : 0
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = aws_eks_cluster.cluster[0].name
}

# Output values
output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = var.cloud_provider == "gcp" ? google_container_cluster.primary[0].endpoint : aws_eks_cluster.cluster[0].endpoint
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = var.cluster_name
}

output "database_connection_name" {
  description = "Database connection details"
  value = var.cloud_provider == "gcp" ? google_sql_database_instance.main[0].connection_name : "aws-rds-endpoint"
}