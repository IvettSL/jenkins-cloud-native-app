# Main Terraform Configuration
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment     = var.environment
  cidr_block      = var.vpc_cidr
  az_count        = var.az_count
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  environment        = var.environment
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_id  = module.vpc.cluster_security_group_id
  cluster_version    = var.cluster_version
  node_groups        = var.node_groups
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  security_groups   = [module.vpc.cluster_security_group_id]
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  storage_size      = var.db_storage_size
  database_name     = var.db_name
  database_user     = var.db_user
  database_password = var.db_password
}

# Outputs
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
  sensitive = true
}

output "rds_password" {
  value = var.db_password
  sensitive = true
}