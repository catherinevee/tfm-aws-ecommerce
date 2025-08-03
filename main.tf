# E-commerce Platform Terraform Module
# This module creates a comprehensive e-commerce infrastructure on AWS

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# KMS key for encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
    resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy.id,
      aws_api_gateway_integration.lambda.id,
      aws_api_gateway_method.proxy_root.id,
      aws_api_gateway_integration.lambda_root.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.lambda,
    aws_api_gateway_method.proxy_root,
    aws_api_gateway_integration.lambda_root
  ]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment != null ? var.environment : "dev"  # Default to dev if not specified
}   Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-kms-key"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-key"
  target_key_id = aws_kms_key.main.key_id
}

# Random resources for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_password" "db_password" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# VPC and Networking
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc-${random_string.suffix.result}"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.availability_zones)
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = var.environment == "dev"  # Default: true for dev, false for prod
  enable_vpn_gateway = false

  enable_dns_hostnames = true  # Default: true for DNS resolution
  enable_dns_support   = true  # Default: true for DNS support

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpc-${random_string.suffix.result}"
  })
}

# Security Groups
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere by default
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere by default
  }

  egress {
    from_port   = 0     # Default: All ports
    to_port     = 0
    protocol    = "-1"  # Default: All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Default: Allow to anywhere
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-alb-sg"
  })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432  # Default: PostgreSQL port
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # Default: Allow from ALB only
  }

  egress {
    from_port   = 0     # Default: All ports
    to_port     = 0
    protocol    = "-1"  # Default: All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Default: Allow to anywhere
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-rds-sg"
  })
}

resource "aws_security_group" "elasticache" {
  name_prefix = "${var.project_name}-elasticache-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6379  # Default: Redis port
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # Default: Allow from ALB only
  }

  egress {
    from_port   = 0     # Default: All ports
    to_port     = 0
    protocol    = "-1"  # Default: All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Default: Allow to anywhere
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-elasticache-sg"
  })
}

# S3 Buckets - Enhanced with customizable configurations
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website-${random_string.suffix.result}"
  force_destroy = lookup(var.s3_buckets, "website", {}).force_destroy != null ? var.s3_buckets["website"].force_destroy : false  # Default: false

  tags = merge(var.common_tags, lookup(var.s3_buckets, "website", {}).tags != null ? var.s3_buckets["website"].tags : {}, {
    Name = "${var.project_name}-website-bucket"
  })
}

resource "aws_s3_bucket" "media" {
  bucket = "${var.project_name}-media-${random_string.suffix.result}"
  force_destroy = lookup(var.s3_buckets, "media", {}).force_destroy != null ? var.s3_buckets["media"].force_destroy : false  # Default: false

  tags = merge(var.common_tags, lookup(var.s3_buckets, "media", {}).tags != null ? var.s3_buckets["media"].tags : {}, {
    Name = "${var.project_name}-media-bucket"
  })
}

resource "aws_s3_bucket" "documents" {
  bucket = "${var.project_name}-documents-${random_string.suffix.result}"
  force_destroy = lookup(var.s3_buckets, "documents", {}).force_destroy != null ? var.s3_buckets["documents"].force_destroy : false  # Default: false

  tags = merge(var.common_tags, lookup(var.s3_buckets, "documents", {}).tags != null ? var.s3_buckets["documents"].tags : {}, {
    Name = "${var.project_name}-documents-bucket"
  })
}

# S3 Bucket configurations
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = lookup(var.s3_buckets, "website", {}).public_access_block != null ? lookup(var.s3_buckets["website"].public_access_block, "block_public_acls", false) : false  # Default: false for website bucket
  block_public_policy     = lookup(var.s3_buckets, "website", {}).public_access_block != null ? lookup(var.s3_buckets["website"].public_access_block, "block_public_policy", false) : false  # Default: false for website bucket
  ignore_public_acls      = lookup(var.s3_buckets, "website", {}).public_access_block != null ? lookup(var.s3_buckets["website"].public_access_block, "ignore_public_acls", false) : false  # Default: false for website bucket
  restrict_public_buckets = lookup(var.s3_buckets, "website", {}).public_access_block != null ? lookup(var.s3_buckets["website"].public_access_block, "restrict_public_buckets", false) : false  # Default: false for website bucket
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      },
    ]
  })
}

# S3 bucket versioning and encryption - Enhanced with customizable configurations
resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id
  versioning_configuration {
    status = lookup(var.s3_buckets, "media", {}).versioning_enabled != null ? (var.s3_buckets["media"].versioning_enabled ? "Enabled" : "Disabled") : "Enabled"  # Default: Enabled
    mfa_delete = lookup(var.s3_buckets, "media", {}).mfa_delete != null ? var.s3_buckets["media"].mfa_delete : false  # Default: false
  }
}

resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id
  versioning_configuration {
    status = lookup(var.s3_buckets, "documents", {}).versioning_enabled != null ? (var.s3_buckets["documents"].versioning_enabled ? "Enabled" : "Disabled") : "Enabled"  # Default: Enabled
    mfa_delete = lookup(var.s3_buckets, "documents", {}).mfa_delete != null ? var.s3_buckets["documents"].mfa_delete : false  # Default: false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = lookup(var.s3_buckets, "media", {}).server_side_encryption != null ? lookup(var.s3_buckets["media"].server_side_encryption, "bucket_key_enabled", false) : false  # Default: false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = lookup(var.s3_buckets, "documents", {}).server_side_encryption != null ? lookup(var.s3_buckets["documents"].server_side_encryption, "bucket_key_enabled", false) : false  # Default: false
  }
}

# CloudFront Distribution - Enhanced with customizable configurations
resource "aws_cloudfront_distribution" "website" {
  enabled             = lookup(var.cloudfront_distributions, "website", {}).enabled != null ? var.cloudfront_distributions["website"].enabled : true  # Default: true
  is_ipv6_enabled     = lookup(var.cloudfront_distributions, "website", {}).is_ipv6_enabled != null ? var.cloudfront_distributions["website"].is_ipv6_enabled : true  # Default: true
  default_root_object = lookup(var.cloudfront_distributions, "website", {}).default_root_object != null ? var.cloudfront_distributions["website"].default_root_object : "index.html"  # Default: index.html
  price_class         = lookup(var.cloudfront_distributions, "website", {}).price_class != null ? var.cloudfront_distributions["website"].price_class : "PriceClass_100"  # Default: PriceClass_100
  comment             = lookup(var.cloudfront_distributions, "website", {}).comment != null ? var.cloudfront_distributions["website"].comment : "${var.project_name} website distribution"  # Default: project name
  retain_on_delete    = lookup(var.cloudfront_distributions, "website", {}).retain_on_delete != null ? var.cloudfront_distributions["website"].retain_on_delete : false  # Default: false
  wait_for_deployment = lookup(var.cloudfront_distributions, "website", {}).wait_for_deployment != null ? var.cloudfront_distributions["website"].wait_for_deployment : true  # Default: true
  http_version        = lookup(var.cloudfront_distributions, "website", {}).http_version != null ? var.cloudfront_distributions["website"].http_version : "http2"  # Default: http2

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.media.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.media.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior, "allowed_methods", ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]) : ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]  # Default: All methods
    cached_methods   = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior, "cached_methods", ["GET", "HEAD"]) : ["GET", "HEAD"]  # Default: GET, HEAD
    target_origin_id = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior, "target_origin_id", "S3-${aws_s3_bucket.website.bucket}") : "S3-${aws_s3_bucket.website.bucket}"  # Default: Website S3 bucket

    forwarded_values {
      query_string = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior.forwarded_values, "query_string", false) : false  # Default: false
      cookies {
        forward = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior.forwarded_values.cookies, "forward", "none") : "none"  # Default: none
        whitelisted_names = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior.forwarded_values.cookies, "whitelisted_names", []) : []  # Default: empty list
      }
      headers = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior.forwarded_values, "headers", []) : []  # Default: empty list
    }

    viewer_protocol_policy = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior, "viewer_protocol_policy", "redirect-to-https") : "redirect-to-https"  # Default: redirect-to-https
    min_ttl                = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior, "min_ttl", 0) : 0  # Default: 0
    default_ttl            = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior, "default_ttl", 3600) : 3600  # Default: 3600 (1 hour)
    max_ttl                = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior, "max_ttl", 86400) : 86400  # Default: 86400 (24 hours)
    compress               = lookup(var.cloudfront_distributions, "website", {}).default_cache_behavior != null ? lookup(var.cloudfront_distributions["website"].default_cache_behavior, "compress", true) : true  # Default: true
  }

  ordered_cache_behavior {
    path_pattern     = "/media/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.media.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  custom_error_response {
    error_code         = 404
    response_code      = "200"
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-cloudfront"
  })
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "OAI for ${var.project_name} website"
}

resource "aws_cloudfront_origin_access_identity" "media" {
  comment = "OAI for ${var.project_name} media"
}

# RDS Database
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"

  engine         = lookup(var.rds_instances, "main", {}).engine != null ? var.rds_instances["main"].engine : "postgres"  # Default: postgres
  engine_version = lookup(var.rds_instances, "main", {}).engine_version != null ? var.rds_instances["main"].engine_version : "14"  # Default: 14
  instance_class = lookup(var.rds_instances, "main", {}).instance_class != null ? var.rds_instances["main"].instance_class : var.rds_instance_class  # Default: from variable

  allocated_storage     = lookup(var.rds_instances, "main", {}).allocated_storage != null ? var.rds_instances["main"].allocated_storage : var.rds_allocated_storage  # Default: from variable
  max_allocated_storage = lookup(var.rds_instances, "main", {}).max_allocated_storage != null ? var.rds_instances["main"].max_allocated_storage : var.rds_max_allocated_storage  # Default: from variable
  storage_type          = lookup(var.rds_instances, "main", {}).storage_type != null ? var.rds_instances["main"].storage_type : "gp2"  # Default: gp2
  storage_encrypted     = lookup(var.rds_instances, "main", {}).storage_encrypted != null ? var.rds_instances["main"].storage_encrypted : true  # Default: true
  kms_key_id           = lookup(var.rds_instances, "main", {}).kms_key_id != null ? var.rds_instances["main"].kms_key_id : aws_kms_key.main.arn  # Default: main KMS key

  db_name  = lookup(var.rds_instances, "main", {}).db_name != null ? var.rds_instances["main"].db_name : var.db_name  # Default: from variable
  username = lookup(var.rds_instances, "main", {}).username != null ? var.rds_instances["main"].username : var.db_username  # Default: from variable
  password = random_password.db_password.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = lookup(var.rds_instances, "main", {}).backup_retention_period != null ? var.rds_instances["main"].backup_retention_period : var.rds_backup_retention_period  # Default: from variable
  backup_window          = lookup(var.rds_instances, "main", {}).backup_window != null ? var.rds_instances["main"].backup_window : "03:00-04:00"  # Default: 03:00-04:00
  maintenance_window     = lookup(var.rds_instances, "main", {}).maintenance_window != null ? var.rds_instances["main"].maintenance_window : "sun:04:00-sun:05:00"  # Default: sun:04:00-sun:05:00

  skip_final_snapshot = lookup(var.rds_instances, "main", {}).skip_final_snapshot != null ? var.rds_instances["main"].skip_final_snapshot : (var.environment == "dev")  # Default: true for dev, false for prod
  deletion_protection = lookup(var.rds_instances, "main", {}).deletion_protection != null ? var.rds_instances["main"].deletion_protection : (var.environment == "prod")  # Default: false for dev, true for prod

  tags = merge(var.common_tags, lookup(var.rds_instances, "main", {}).tags != null ? var.rds_instances["main"].tags : {}, {
    Name = "${var.project_name}-db"
  })
}

# DynamoDB Tables - Enhanced with customizable configurations
resource "aws_dynamodb_table" "carts" {
  name           = lookup(var.dynamodb_tables, "carts", {}).name != null ? var.dynamodb_tables["carts"].name : "${var.project_name}-carts"  # Default: project name + carts
  billing_mode   = lookup(var.dynamodb_tables, "carts", {}).billing_mode != null ? var.dynamodb_tables["carts"].billing_mode : "PAY_PER_REQUEST"  # Default: PAY_PER_REQUEST
  hash_key       = lookup(var.dynamodb_tables, "carts", {}).hash_key != null ? var.dynamodb_tables["carts"].hash_key : "user_id"  # Default: user_id
  range_key      = lookup(var.dynamodb_tables, "carts", {}).range_key != null ? var.dynamodb_tables["carts"].range_key : "cart_id"  # Default: cart_id

  read_capacity  = lookup(var.dynamodb_tables, "carts", {}).read_capacity != null ? var.dynamodb_tables["carts"].read_capacity : null  # Default: null (for PAY_PER_REQUEST)
  write_capacity = lookup(var.dynamodb_tables, "carts", {}).write_capacity != null ? var.dynamodb_tables["carts"].write_capacity : null  # Default: null (for PAY_PER_REQUEST)

  stream_enabled   = lookup(var.dynamodb_tables, "carts", {}).stream_enabled != null ? var.dynamodb_tables["carts"].stream_enabled : false  # Default: false
  stream_view_type = lookup(var.dynamodb_tables, "carts", {}).stream_view_type != null ? var.dynamodb_tables["carts"].stream_view_type : null  # Default: null

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "cart_id"
    type = "S"
  }

  tags = merge(var.common_tags, lookup(var.dynamodb_tables, "carts", {}).tags != null ? var.dynamodb_tables["carts"].tags : {}, {
    Name = "${var.project_name}-carts-table"
  })
}

resource "aws_dynamodb_table" "sessions" {
  name           = lookup(var.dynamodb_tables, "sessions", {}).name != null ? var.dynamodb_tables["sessions"].name : "${var.project_name}-sessions"  # Default: project name + sessions
  billing_mode   = lookup(var.dynamodb_tables, "sessions", {}).billing_mode != null ? var.dynamodb_tables["sessions"].billing_mode : "PAY_PER_REQUEST"  # Default: PAY_PER_REQUEST
  hash_key       = lookup(var.dynamodb_tables, "sessions", {}).hash_key != null ? var.dynamodb_tables["sessions"].hash_key : "session_id"  # Default: session_id

  read_capacity  = lookup(var.dynamodb_tables, "sessions", {}).read_capacity != null ? var.dynamodb_tables["sessions"].read_capacity : null  # Default: null (for PAY_PER_REQUEST)
  write_capacity = lookup(var.dynamodb_tables, "sessions", {}).write_capacity != null ? var.dynamodb_tables["sessions"].write_capacity : null  # Default: null (for PAY_PER_REQUEST)

  stream_enabled   = lookup(var.dynamodb_tables, "sessions", {}).stream_enabled != null ? var.dynamodb_tables["sessions"].stream_enabled : false  # Default: false
  stream_view_type = lookup(var.dynamodb_tables, "sessions", {}).stream_view_type != null ? var.dynamodb_tables["sessions"].stream_view_type : null  # Default: null

  attribute {
    name = "session_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = merge(var.common_tags, lookup(var.dynamodb_tables, "sessions", {}).tags != null ? var.dynamodb_tables["sessions"].tags : {}, {
    Name = "${var.project_name}-sessions-table"
  })
}

# ElastiCache Redis
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-cache-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_parameter_group" "main" {
  family = "redis7"
  name   = "${var.project_name}-cache-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = lookup(var.elasticache_clusters, "main", {}).replication_group_id != null ? var.elasticache_clusters["main"].replication_group_id : "${var.project_name}-cache"  # Default: project name + cache
  description                = lookup(var.elasticache_clusters, "main", {}).description != null ? var.elasticache_clusters["main"].description : "Redis cluster for ${var.project_name}"  # Default: Redis cluster description
  node_type                  = lookup(var.elasticache_clusters, "main", {}).node_type != null ? var.elasticache_clusters["main"].node_type : var.elasticache_node_type  # Default: from variable
  port                       = lookup(var.elasticache_clusters, "main", {}).port != null ? var.elasticache_clusters["main"].port : 6379  # Default: 6379 (Redis port)
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.elasticache.id]
  automatic_failover_enabled = lookup(var.elasticache_clusters, "main", {}).automatic_failover_enabled != null ? var.elasticache_clusters["main"].automatic_failover_enabled : (var.environment == "prod")  # Default: true for prod, false for dev
  num_cache_clusters         = lookup(var.elasticache_clusters, "main", {}).num_cache_clusters != null ? var.elasticache_clusters["main"].num_cache_clusters : (var.environment == "prod" ? 2 : 1)  # Default: 2 for prod, 1 for dev

  tags = merge(var.common_tags, lookup(var.elasticache_clusters, "main", {}).tags != null ? var.elasticache_clusters["main"].tags : {}, {
    Name = "${var.project_name}-cache"
  })
}

# Cognito User Pool - Enhanced with customizable configurations
resource "aws_cognito_user_pool" "main" {
  name = lookup(var.cognito_user_pools, "main", {}).name != null ? var.cognito_user_pools["main"].name : "${var.project_name}-user-pool"  # Default: project name + user-pool

  password_policy {
    minimum_length    = lookup(var.cognito_user_pools, "main", {}).password_policy != null ? lookup(var.cognito_user_pools["main"].password_policy, "minimum_length", 8) : 8  # Default: 8
    require_lowercase = lookup(var.cognito_user_pools, "main", {}).password_policy != null ? lookup(var.cognito_user_pools["main"].password_policy, "require_lowercase", true) : true  # Default: true
    require_numbers   = lookup(var.cognito_user_pools, "main", {}).password_policy != null ? lookup(var.cognito_user_pools["main"].password_policy, "require_numbers", true) : true  # Default: true
    require_symbols   = lookup(var.cognito_user_pools, "main", {}).password_policy != null ? lookup(var.cognito_user_pools["main"].password_policy, "require_symbols", true) : true  # Default: true
    require_uppercase = lookup(var.cognito_user_pools, "main", {}).password_policy != null ? lookup(var.cognito_user_pools["main"].password_policy, "require_uppercase", true) : true  # Default: true
  }

  auto_verified_attributes = lookup(var.cognito_user_pools, "main", {}).auto_verified_attributes != null ? var.cognito_user_pools["main"].auto_verified_attributes : ["email"]  # Default: ["email"]

  verification_message_template {
    default_email_option = lookup(var.cognito_user_pools, "main", {}).verification_message_template != null ? lookup(var.cognito_user_pools["main"].verification_message_template, "default_email_option", "CONFIRM_WITH_CODE") : "CONFIRM_WITH_CODE"  # Default: CONFIRM_WITH_CODE
  }

  email_configuration {
    email_sending_account = lookup(var.cognito_user_pools, "main", {}).email_configuration != null ? lookup(var.cognito_user_pools["main"].email_configuration, "email_sending_account", "COGNITO_DEFAULT") : "COGNITO_DEFAULT"  # Default: COGNITO_DEFAULT
  }

  tags = merge(var.common_tags, lookup(var.cognito_user_pools, "main", {}).tags != null ? var.cognito_user_pools["main"].tags : {}, {
    Name = "${var.project_name}-user-pool"
  })
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

# SQS Queues - Enhanced with customizable configurations
resource "aws_sqs_queue" "orders" {
  name = lookup(var.sqs_queues, "orders", {}).name != null ? var.sqs_queues["orders"].name : "${var.project_name}-orders-queue"  # Default: project name + orders-queue
  kms_master_key_id = aws_kms_key.main.arn
  sqs_managed_sse_enabled = false

  visibility_timeout_seconds = lookup(var.sqs_queues, "orders", {}).visibility_timeout_seconds != null ? var.sqs_queues["orders"].visibility_timeout_seconds : 300  # Default: 300 seconds
  message_retention_seconds  = lookup(var.sqs_queues, "orders", {}).message_retention_seconds != null ? var.sqs_queues["orders"].message_retention_seconds : 1209600  # Default: 14 days
  delay_seconds              = lookup(var.sqs_queues, "orders", {}).delay_seconds != null ? var.sqs_queues["orders"].delay_seconds : 0  # Default: 0 seconds
  receive_wait_time_seconds  = lookup(var.sqs_queues, "orders", {}).receive_wait_time_seconds != null ? var.sqs_queues["orders"].receive_wait_time_seconds : 20  # Default: 20 seconds
  max_message_size           = lookup(var.sqs_queues, "orders", {}).max_message_size != null ? var.sqs_queues["orders"].max_message_size : 262144  # Default: 256 KB

  tags = merge(var.common_tags, lookup(var.sqs_queues, "orders", {}).tags != null ? var.sqs_queues["orders"].tags : {}, {
    Name = "${var.project_name}-orders-queue"
  })
}

resource "aws_sqs_queue" "notifications" {
  name = lookup(var.sqs_queues, "notifications", {}).name != null ? var.sqs_queues["notifications"].name : "${var.project_name}-notifications-queue"  # Default: project name + notifications-queue
  kms_master_key_id = aws_kms_key.main.arn
  sqs_managed_sse_enabled = false

  visibility_timeout_seconds = lookup(var.sqs_queues, "notifications", {}).visibility_timeout_seconds != null ? var.sqs_queues["notifications"].visibility_timeout_seconds : 300  # Default: 300 seconds
  message_retention_seconds  = lookup(var.sqs_queues, "notifications", {}).message_retention_seconds != null ? var.sqs_queues["notifications"].message_retention_seconds : 1209600  # Default: 14 days
  delay_seconds              = lookup(var.sqs_queues, "notifications", {}).delay_seconds != null ? var.sqs_queues["notifications"].delay_seconds : 0  # Default: 0 seconds
  receive_wait_time_seconds  = lookup(var.sqs_queues, "notifications", {}).receive_wait_time_seconds != null ? var.sqs_queues["notifications"].receive_wait_time_seconds : 20  # Default: 20 seconds
  max_message_size           = lookup(var.sqs_queues, "notifications", {}).max_message_size != null ? var.sqs_queues["notifications"].max_message_size : 262144  # Default: 256 KB

  tags = merge(var.common_tags, lookup(var.sqs_queues, "notifications", {}).tags != null ? var.sqs_queues["notifications"].tags : {}, {
    Name = "${var.project_name}-notifications-queue"
  })
}

# SNS Topics
resource "aws_sns_topic" "order_notifications" {
  name = "${var.project_name}-order-notifications"
  kms_master_key_id = aws_kms_key.main.arn

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-order-notifications"
  })
}

resource "aws_sns_topic" "system_alerts" {
  name = "${var.project_name}-system-alerts"
  kms_master_key_id = aws_kms_key.main.arn

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-system-alerts"
  })
}

# IAM Roles and Policies
resource "aws_iam_role" "lambda_execution" {
  name = "${var.project_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-lambda-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${var.project_name}-lambda-dynamodb-policy"
  description = "Policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.carts.arn,
          aws_dynamodb_table.sessions.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

resource "aws_iam_policy" "lambda_sqs" {
  name        = "${var.project_name}-lambda-sqs-policy"
  description = "Policy for Lambda to access SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.orders.arn,
          aws_sqs_queue.notifications.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_sqs.arn
}

# Lambda Functions - Enhanced with customizable configurations
resource "aws_lambda_function" "api_handler" {
  filename         = lookup(var.lambda_functions, "api_handler", {}).filename != null ? var.lambda_functions["api_handler"].filename : "lambda/api_handler.zip"  # Default: lambda/api_handler.zip
  function_name    = lookup(var.lambda_functions, "api_handler", {}).function_name != null ? var.lambda_functions["api_handler"].function_name : "${var.project_name}-api-handler"  # Default: project name + api-handler
  role            = aws_iam_role.lambda_execution.arn
  handler         = lookup(var.lambda_functions, "api_handler", {}).handler != null ? var.lambda_functions["api_handler"].handler : "index.handler"  # Default: index.handler
  runtime         = lookup(var.lambda_functions, "api_handler", {}).runtime != null ? var.lambda_functions["api_handler"].runtime : "nodejs18.x"  # Default: nodejs18.x
  timeout         = lookup(var.lambda_functions, "api_handler", {}).timeout != null ? var.lambda_functions["api_handler"].timeout : 30  # Default: 30 seconds
  memory_size     = lookup(var.lambda_functions, "api_handler", {}).memory_size != null ? var.lambda_functions["api_handler"].memory_size : 512  # Default: 512 MB

  environment {
    variables = {
      DB_HOST     = aws_db_instance.main.endpoint
      DB_NAME     = aws_db_instance.main.db_name
      DB_USER     = aws_db_instance.main.username
      DB_PASSWORD = random_password.db_password.result
      REDIS_HOST  = aws_elasticache_replication_group.main.primary_endpoint_address
      REDIS_PORT  = "6379"
      CART_TABLE  = aws_dynamodb_table.carts.name
      SESSION_TABLE = aws_dynamodb_table.sessions.name
      ORDERS_QUEUE = aws_sqs_queue.orders.url
      NOTIFICATIONS_QUEUE = aws_sqs_queue.notifications.url
      USER_POOL_ID = aws_cognito_user_pool.main.id
      USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.main.id
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-api-handler"
  })
}

resource "aws_lambda_function" "order_processor" {
  filename         = "lambda/order_processor.zip"
  function_name    = "${var.project_name}-order-processor"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 60
  memory_size     = 1024

  environment {
    variables = {
      DB_HOST     = aws_db_instance.main.endpoint
      DB_NAME     = aws_db_instance.main.db_name
      DB_USER     = aws_db_instance.main.username
      DB_PASSWORD = random_password.db_password.result
      NOTIFICATIONS_TOPIC = aws_sns_topic.order_notifications.arn
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-order-processor"
  })
}

# API Gateway
resource "aws_api_gateway_rest_api" "main" {
  name = "${var.project_name}-api"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-api"
  })
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.api_handler.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.api_handler.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy.id,
      aws_api_gateway_integration.lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id  = aws_api_gateway_rest_api.main.id
  stage_name   = coalesce(var.environment, "dev")

  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format         = jsonencode({
      requestId       = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-api-logs"
  })
}

# Step Functions
resource "aws_sfn_state_machine" "order_workflow" {
  name     = "${var.project_name}-order-workflow"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Order processing workflow"
    StartAt = "ValidateOrder"
    States = {
      ValidateOrder = {
        Type = "Task"
        Resource = aws_lambda_function.api_handler.arn
        Next = "ProcessPayment"
      }
      ProcessPayment = {
        Type = "Task"
        Resource = aws_lambda_function.api_handler.arn
        Next = "UpdateInventory"
      }
      UpdateInventory = {
        Type = "Task"
        Resource = aws_lambda_function.api_handler.arn
        Next = "SendNotification"
      }
      SendNotification = {
        Type = "Task"
        Resource = aws_lambda_function.api_handler.arn
        End = true
      }
    }
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-order-workflow"
  })
}

resource "aws_iam_role" "step_functions" {
  name = "${var.project_name}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_functions_lambda" {
  name = "${var.project_name}-step-functions-lambda-policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.api_handler.arn,
          aws_lambda_function.order_processor.arn
        ]
      }
    ]
  })
}

# SQS Event Source Mapping
resource "aws_lambda_event_source_mapping" "order_processor" {
  event_source_arn = aws_sqs_queue.orders.arn
  function_name    = aws_lambda_function.order_processor.arn
  batch_size       = 1
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "api_handler" {
  name              = "/aws/lambda/${aws_lambda_function.api_handler.function_name}"
  retention_in_days = 14

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-api-handler-logs"
  })
}

resource "aws_cloudwatch_log_group" "order_processor" {
  name              = "/aws/lambda/${aws_lambda_function.order_processor.function_name}"
  retention_in_days = 14

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-order-processor-logs"
  })
} 