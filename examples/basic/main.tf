# Basic E-commerce Platform Example
# This example demonstrates a basic deployment of the e-commerce platform
# with comments about default values and customization options

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
  project_name = "my-ecommerce-app"  # Default: "ecommerce-platform"
  environment  = "dev"               # Default: "dev" (options: dev, staging, prod)

  # VPC Configuration
  vpc_cidr             = "10.0.0.0/16"  # Default: "10.0.0.0/16"
  availability_zones   = 2              # Default: 2 (range: 1-4)
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]  # Default: ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]  # Default: ["10.0.101.0/24", "10.0.102.0/24"]

  # RDS Configuration
  rds_instance_class        = "db.t3.micro"  # Default: "db.t3.micro"
  rds_allocated_storage     = 20             # Default: 20 GB (range: 20-65536)
  rds_max_allocated_storage = 100            # Default: 100 GB
  rds_backup_retention_period = 7            # Default: 7 days (range: 0-35)

  # ElastiCache Configuration
  elasticache_node_type = "cache.t3.micro"  # Default: "cache.t3.micro"

  # Lambda Configuration
  lambda_timeout    = 30   # Default: 30 seconds (range: 3-900)
  lambda_memory_size = 512 # Default: 512 MB (range: 128-10240)

  # CloudFront Configuration
  cloudfront_price_class = "PriceClass_100"  # Default: "PriceClass_100" (options: PriceClass_100, PriceClass_200, PriceClass_All)

  # SQS Configuration
  sqs_visibility_timeout = 300     # Default: 300 seconds (range: 0-43200)
  sqs_message_retention = 1209600  # Default: 1209600 seconds (14 days, range: 60-1209600)

  # CloudWatch Configuration
  log_retention_days = 14  # Default: 14 days

  # Feature Flags
  enable_auto_scaling = false  # Default: false
  enable_monitoring  = true    # Default: true
  enable_backup      = true    # Default: true
  enable_encryption  = true    # Default: true

  # Enhanced S3 Configuration Example
  s3_buckets = {
    website = {
      force_destroy = false  # Default: false
      versioning_enabled = false  # Default: false
      mfa_delete = false  # Default: false
      server_side_encryption = {
        sse_algorithm = "AES256"  # Default: "AES256"
        kms_master_key_id = null  # Default: null
        bucket_key_enabled = false  # Default: false
      }
      public_access_block = {
        block_public_acls = false  # Default: false for website bucket
        block_public_policy = false  # Default: false for website bucket
        ignore_public_acls = false  # Default: false for website bucket
        restrict_public_buckets = false  # Default: false for website bucket
      }
      tags = {
        Purpose = "website-hosting"
      }
    }
    media = {
      force_destroy = false  # Default: false
      versioning_enabled = true  # Default: true
      mfa_delete = false  # Default: false
      server_side_encryption = {
        sse_algorithm = "AES256"  # Default: "AES256"
        kms_master_key_id = null  # Default: null
        bucket_key_enabled = false  # Default: false
      }
      public_access_block = {
        block_public_acls = true  # Default: true
        block_public_policy = true  # Default: true
        ignore_public_acls = true  # Default: true
        restrict_public_buckets = true  # Default: true
      }
      tags = {
        Purpose = "media-storage"
      }
    }
  }

  # Enhanced CloudFront Configuration Example
  cloudfront_distributions = {
    website = {
      enabled = true  # Default: true
      is_ipv6_enabled = true  # Default: true
      default_root_object = "index.html"  # Default: "index.html"
      price_class = "PriceClass_100"  # Default: "PriceClass_100"
      comment = "My E-commerce Website Distribution"  # Default: project name + description
      retain_on_delete = false  # Default: false
      wait_for_deployment = true  # Default: true
      http_version = "http2"  # Default: "http2"
      default_cache_behavior = {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]  # Default: All methods
        cached_methods = ["GET", "HEAD"]  # Default: ["GET", "HEAD"]
        target_origin_id = "S3-my-ecommerce-app-website"  # Default: Website S3 bucket
        forwarded_values = {
          query_string = false  # Default: false
          headers = []  # Default: empty list
          cookies = {
            forward = "none"  # Default: "none"
            whitelisted_names = []  # Default: empty list
          }
        }
        viewer_protocol_policy = "redirect-to-https"  # Default: "redirect-to-https"
        min_ttl = 0  # Default: 0
        default_ttl = 3600  # Default: 3600 (1 hour)
        max_ttl = 86400  # Default: 86400 (24 hours)
        compress = true  # Default: true
      }
      tags = {
        Purpose = "website-cdn"
      }
    }
  }

  # Enhanced RDS Configuration Example
  rds_instances = {
    main = {
      engine = "postgres"  # Default: "postgres"
      engine_version = "14"  # Default: "14"
      instance_class = "db.t3.micro"  # Default: from variable
      allocated_storage = 20  # Default: from variable
      max_allocated_storage = 100  # Default: from variable
      storage_type = "gp2"  # Default: "gp2"
      storage_encrypted = true  # Default: true
      db_name = "ecommerce"  # Default: from variable
      username = "ecommerce_admin"  # Default: from variable
      backup_retention_period = 7  # Default: from variable
      backup_window = "03:00-04:00"  # Default: "03:00-04:00"
      maintenance_window = "sun:04:00-sun:05:00"  # Default: "sun:04:00-sun:05:00"
      skip_final_snapshot = true  # Default: true for dev, false for prod
      deletion_protection = false  # Default: false for dev, true for prod
      multi_az = false  # Default: false
      publicly_accessible = false  # Default: false
      port = 5432  # Default: 5432
      tags = {
        Purpose = "ecommerce-database"
      }
    }
  }

  # Enhanced DynamoDB Configuration Example
  dynamodb_tables = {
    carts = {
      name = "my-ecommerce-app-carts"  # Default: project name + carts
      billing_mode = "PAY_PER_REQUEST"  # Default: "PAY_PER_REQUEST"
      hash_key = "user_id"  # Default: "user_id"
      range_key = "cart_id"  # Default: "cart_id"
      read_capacity = null  # Default: null (for PAY_PER_REQUEST)
      write_capacity = null  # Default: null (for PAY_PER_REQUEST)
      stream_enabled = false  # Default: false
      stream_view_type = null  # Default: null
      tags = {
        Purpose = "shopping-carts"
      }
    }
    sessions = {
      name = "my-ecommerce-app-sessions"  # Default: project name + sessions
      billing_mode = "PAY_PER_REQUEST"  # Default: "PAY_PER_REQUEST"
      hash_key = "session_id"  # Default: "session_id"
      range_key = null  # Default: null
      read_capacity = null  # Default: null (for PAY_PER_REQUEST)
      write_capacity = null  # Default: null (for PAY_PER_REQUEST)
      stream_enabled = false  # Default: false
      stream_view_type = null  # Default: null
      tags = {
        Purpose = "user-sessions"
      }
    }
  }

  # Enhanced ElastiCache Configuration Example
  elasticache_clusters = {
    main = {
      replication_group_id = "my-ecommerce-app-cache"  # Default: project name + cache
      description = "Redis cluster for my e-commerce application"  # Default: Redis cluster description
      node_type = "cache.t3.micro"  # Default: from variable
      port = 6379  # Default: 6379 (Redis port)
      automatic_failover_enabled = false  # Default: true for prod, false for dev
      num_cache_clusters = 1  # Default: 2 for prod, 1 for dev
      engine = "redis"  # Default: "redis"
      engine_version = "7.0"  # Default: "7.0"
      at_rest_encryption_enabled = true  # Default: true
      transit_encryption_enabled = true  # Default: true
      tags = {
        Purpose = "application-cache"
      }
    }
  }

  # Enhanced Cognito Configuration Example
  cognito_user_pools = {
    main = {
      name = "my-ecommerce-app-user-pool"  # Default: project name + user-pool
      password_policy = {
        minimum_length = 8  # Default: 8
        require_lowercase = true  # Default: true
        require_numbers = true  # Default: true
        require_symbols = true  # Default: true
        require_uppercase = true  # Default: true
        temporary_password_validity_days = 7  # Default: 7
      }
      auto_verified_attributes = ["email"]  # Default: ["email"]
      verification_message_template = {
        default_email_option = "CONFIRM_WITH_CODE"  # Default: "CONFIRM_WITH_CODE"
        email_subject = null  # Default: null
        email_message = null  # Default: null
        sms_message = null  # Default: null
      }
      email_configuration = {
        email_sending_account = "COGNITO_DEFAULT"  # Default: "COGNITO_DEFAULT"
        from_email_address = null  # Default: null
        reply_to_email_address = null  # Default: null
        source_arn = null  # Default: null
      }
      tags = {
        Purpose = "user-authentication"
      }
    }
  }

  # Enhanced SQS Configuration Example
  sqs_queues = {
    orders = {
      name = "my-ecommerce-app-orders-queue"  # Default: project name + orders-queue
      visibility_timeout_seconds = 300  # Default: 300 seconds
      message_retention_seconds = 1209600  # Default: 1209600 seconds (14 days)
      delay_seconds = 0  # Default: 0 seconds
      receive_wait_time_seconds = 20  # Default: 20 seconds
      max_message_size = 262144  # Default: 256 KB
      tags = {
        Purpose = "order-processing"
      }
    }
    notifications = {
      name = "my-ecommerce-app-notifications-queue"  # Default: project name + notifications-queue
      visibility_timeout_seconds = 300  # Default: 300 seconds
      message_retention_seconds = 1209600  # Default: 1209600 seconds (14 days)
      delay_seconds = 0  # Default: 0 seconds
      receive_wait_time_seconds = 20  # Default: 20 seconds
      max_message_size = 262144  # Default: 256 KB
      tags = {
        Purpose = "notifications"
      }
    }
  }

  # Enhanced Lambda Configuration Example
  lambda_functions = {
    api_handler = {
      filename = "lambda/api_handler.zip"  # Default: "lambda/api_handler.zip"
      function_name = "my-ecommerce-app-api-handler"  # Default: project name + api-handler
      handler = "index.handler"  # Default: "index.handler"
      runtime = "nodejs18.x"  # Default: "nodejs18.x"
      timeout = 30  # Default: 30 seconds
      memory_size = 512  # Default: 512 MB
      description = "API handler for e-commerce application"  # Default: null
      reserved_concurrent_executions = null  # Default: null
      publish = false  # Default: false
      layers = []  # Default: empty list
      environment = {
        variables = {
          NODE_ENV = "production"
          LOG_LEVEL = "info"
        }
      }
      tags = {
        Purpose = "api-handling"
      }
    }
    order_processor = {
      filename = "lambda/order_processor.zip"  # Default: "lambda/order_processor.zip"
      function_name = "my-ecommerce-app-order-processor"  # Default: project name + order-processor
      handler = "index.handler"  # Default: "index.handler"
      runtime = "nodejs18.x"  # Default: "nodejs18.x"
      timeout = 60  # Default: 60 seconds
      memory_size = 1024  # Default: 1024 MB
      description = "Order processing function"  # Default: null
      reserved_concurrent_executions = null  # Default: null
      publish = false  # Default: false
      layers = []  # Default: empty list
      environment = {
        variables = {
          NODE_ENV = "production"
          LOG_LEVEL = "info"
        }
      }
      tags = {
        Purpose = "order-processing"
      }
    }
  }

  # Common Tags
  common_tags = {
    Environment = "dev"
    Project     = "my-ecommerce-app"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }
} 