# Test Configuration for E-commerce Platform Module
# This configuration is used for testing the module functionality

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

# Test the module with minimal configuration
module "ecommerce_platform_test" {
  source = "../"

  # Minimal test configuration
  project_name = "test-ecommerce"
  environment  = "dev"

  # Minimal VPC configuration
  vpc_cidr             = "10.1.0.0/16"
  availability_zones   = 1
  private_subnet_cidrs = ["10.1.1.0/24"]
  public_subnet_cidrs  = ["10.1.101.0/24"]

  # Minimal resource configuration
  rds_instance_class        = "db.t3.micro"
  rds_allocated_storage     = 20
  rds_max_allocated_storage = 50
  elasticache_node_type     = "cache.t3.micro"
  lambda_timeout            = 30
  lambda_memory_size        = 512

  # Disable expensive features for testing
  enable_auto_scaling = false
  enable_monitoring   = true
  enable_backup       = false
  enable_encryption   = true

  # Test tags
  common_tags = {
    Environment = "test"
    Project     = "test-ecommerce"
    ManagedBy   = "terraform"
    TestRun     = "true"
  }
} 