# Production E-commerce Platform Example
# This example demonstrates a production-ready deployment with enhanced security and performance

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

  # Production Configuration
  project_name = "prod-ecommerce-app"
  environment  = "prod"

  # VPC Configuration - Multi-AZ for high availability
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = 3
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # RDS Configuration - Production-grade database
  rds_instance_class        = "db.r6g.large"
  rds_allocated_storage     = 100
  rds_max_allocated_storage = 1000
  rds_backup_retention_period = 30

  # ElastiCache Configuration - Multi-node for high availability
  elasticache_node_type = "cache.r6g.large"

  # Lambda Configuration - Enhanced performance
  lambda_timeout    = 60
  lambda_memory_size = 1024

  # CloudFront Configuration - Global distribution
  cloudfront_price_class = "PriceClass_200"

  # SQS Configuration - Production settings
  sqs_visibility_timeout = 600
  sqs_message_retention  = 1209600

  # CloudWatch Configuration - Extended log retention
  log_retention_days = 90

  # Custom Domain (if available)
  domain_name    = "myecommerce.com"
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-certificate-id"

  # Feature Flags - Production features enabled
  enable_auto_scaling = true
  enable_monitoring   = true
  enable_backup       = true
  enable_encryption   = true

  # Common Tags - Production tagging
  common_tags = {
    Environment = "production"
    Project     = "prod-ecommerce-app"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
    CostCenter  = "ecommerce-platform"
    Compliance  = "pci-dss"
  }
} 