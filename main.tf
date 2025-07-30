# E-commerce Platform Terraform Module
# This module creates a comprehensive e-commerce infrastructure on AWS

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
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
  single_nat_gateway = var.environment == "dev"
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpc-${random_string.suffix.result}"
  })
}

# Security Groups
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-alb-sg"
  })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-rds-sg"
  })
}

resource "aws_security_group" "elasticache" {
  name_prefix = "${var.project_name}-elasticache-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-elasticache-sg"
  })
}

# S3 Buckets
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website-${random_string.suffix.result}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-website-bucket"
  })
}

resource "aws_s3_bucket" "media" {
  bucket = "${var.project_name}-media-${random_string.suffix.result}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-media-bucket"
  })
}

resource "aws_s3_bucket" "documents" {
  bucket = "${var.project_name}-documents-${random_string.suffix.result}"

  tags = merge(var.common_tags, {
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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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

# S3 bucket versioning and encryption
resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

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
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
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

  engine         = "postgres"
  engine_version = "14"
  instance_class = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = var.rds_backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  skip_final_snapshot = var.environment == "dev"
  deletion_protection = var.environment == "prod"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db"
  })
}

# DynamoDB Tables
resource "aws_dynamodb_table" "carts" {
  name           = "${var.project_name}-carts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = "cart_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "cart_id"
    type = "S"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-carts-table"
  })
}

resource "aws_dynamodb_table" "sessions" {
  name           = "${var.project_name}-sessions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "session_id"

  attribute {
    name = "session_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = merge(var.common_tags, {
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
  replication_group_id       = "${var.project_name}-cache"
  description                = "Redis cluster for ${var.project_name}"
  node_type                  = var.elasticache_node_type
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.elasticache.id]
  automatic_failover_enabled = var.environment == "prod"
  num_cache_clusters         = var.environment == "prod" ? 2 : 1

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-cache"
  })
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  tags = merge(var.common_tags, {
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

# SQS Queues
resource "aws_sqs_queue" "orders" {
  name = "${var.project_name}-orders-queue"

  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600
  delay_seconds              = 0
  receive_wait_time_seconds  = 20

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-orders-queue"
  })
}

resource "aws_sqs_queue" "notifications" {
  name = "${var.project_name}-notifications-queue"

  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600
  delay_seconds              = 0
  receive_wait_time_seconds  = 20

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-notifications-queue"
  })
}

# SNS Topics
resource "aws_sns_topic" "order_notifications" {
  name = "${var.project_name}-order-notifications"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-order-notifications"
  })
}

resource "aws_sns_topic" "system_alerts" {
  name = "${var.project_name}-system-alerts"

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

# Lambda Functions
resource "aws_lambda_function" "api_handler" {
  filename         = "lambda/api_handler.zip"
  function_name    = "${var.project_name}-api-handler"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30
  memory_size     = 512

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
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.environment
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