provider "aws" {
  region = "us-west-2"
}

module "ecommerce_platform" {
  source = "../.."

  project_name = "demo-ecommerce"
  environment  = "dev"

  # VPC Configuration
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = 2
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Security Configuration
  alb_allowed_cidr_blocks = ["10.0.0.0/8"]  # Restrict access to internal network

  # S3 Configuration
  s3_buckets = {
    website = {
      force_destroy = true
      versioning_enabled = true
      server_side_encryption = {
        sse_algorithm = "AES256"
      }
      public_access_block = {
        block_public_acls = false
        block_public_policy = false
        ignore_public_acls = false
        restrict_public_buckets = false
      }
    }
    media = {
      force_destroy = true
      versioning_enabled = true
      server_side_encryption = {
        sse_algorithm = "aws:kms"
        bucket_key_enabled = true
      }
    }
    documents = {
      force_destroy = true
      versioning_enabled = true
      server_side_encryption = {
        sse_algorithm = "aws:kms"
        bucket_key_enabled = true
      }
    }
  }

  # RDS Configuration
  rds_instance_class = "db.t3.small"
  db_name = "ecommerce"
  db_username = "admin"
  rds_allocated_storage = 20
  rds_max_allocated_storage = 100
  rds_backup_retention_period = 7

  # ElastiCache Configuration
  elasticache_node_type = "cache.t3.micro"

  # Common Tags
  common_tags = {
    Environment = "dev"
    Project     = "demo-ecommerce"
    Terraform   = "true"
  }
}
