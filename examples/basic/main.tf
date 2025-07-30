# Basic E-commerce Platform Example
# This example demonstrates a basic deployment of the e-commerce platform

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ecommerce_platform" {
  source = "../../"

  # Basic Configuration
  project_name = "my-ecommerce-app"
  environment  = "dev"

  # VPC Configuration
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = 2
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

  # RDS Configuration
  rds_instance_class        = "db.t3.micro"
  rds_allocated_storage     = 20
  rds_max_allocated_storage = 100
  rds_backup_retention_period = 7

  # ElastiCache Configuration
  elasticache_node_type = "cache.t3.micro"

  # Lambda Configuration
  lambda_timeout    = 30
  lambda_memory_size = 512

  # Common Tags
  common_tags = {
    Environment = "dev"
    Project     = "my-ecommerce-app"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }
} 