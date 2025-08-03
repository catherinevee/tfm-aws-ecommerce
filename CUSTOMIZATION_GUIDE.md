# E-commerce Platform Customization Guide

This guide provides detailed information about all customizable parameters in the AWS E-commerce Platform Terraform module.

## Table of Contents

1. [Basic Configuration](#basic-configuration)
2. [Enhanced S3 Configuration](#enhanced-s3-configuration)
3. [Enhanced CloudFront Configuration](#enhanced-cloudfront-configuration)
4. [Enhanced RDS Configuration](#enhanced-rds-configuration)
5. [Enhanced DynamoDB Configuration](#enhanced-dynamodb-configuration)
6. [Enhanced ElastiCache Configuration](#enhanced-elasticache-configuration)
7. [Enhanced Cognito Configuration](#enhanced-cognito-configuration)
8. [Enhanced SQS Configuration](#enhanced-sqs-configuration)
9. [Enhanced Lambda Configuration](#enhanced-lambda-configuration)
10. [E-commerce Platform Configuration](#e-commerce-platform-configuration)
11. [Payment Processing Configuration](#payment-processing-configuration)
12. [Inventory Management Configuration](#inventory-management-configuration)
13. [Order Management Configuration](#order-management-configuration)
14. [Customer Management Configuration](#customer-management-configuration)
15. [Shipping Configuration](#shipping-configuration)
16. [Tax Configuration](#tax-configuration)
17. [Discount Configuration](#discount-configuration)
18. [Analytics Configuration](#analytics-configuration)
19. [Marketing Configuration](#marketing-configuration)
20. [Security Configuration](#security-configuration)
21. [Integration Configuration](#integration-configuration)
22. [Usage Examples](#usage-examples)
23. [Best Practices](#best-practices)
24. [Troubleshooting](#troubleshooting)

## Basic Configuration

### Core Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project_name` | string | `"ecommerce-platform"` | Name of the project/application |
| `environment` | string | `"dev"` | Environment name (dev, staging, prod) |
| `vpc_cidr` | string | `"10.0.0.0/16"` | CIDR block for VPC |
| `availability_zones` | number | `2` | Number of availability zones (1-4) |
| `private_subnet_cidrs` | list(string) | `["10.0.1.0/24", "10.0.2.0/24"]` | CIDR blocks for private subnets |
| `public_subnet_cidrs` | list(string) | `["10.0.101.0/24", "10.0.102.0/24"]` | CIDR blocks for public subnets |

### RDS Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `rds_instance_class` | string | `"db.t3.micro"` | RDS instance class |
| `rds_allocated_storage` | number | `20` | Allocated storage in GB (20-65536) |
| `rds_max_allocated_storage` | number | `100` | Maximum allocated storage in GB |
| `rds_backup_retention_period` | number | `7` | Backup retention period in days (0-35) |
| `db_name` | string | `"ecommerce"` | Name of the database |
| `db_username` | string | `"ecommerce_admin"` | Database master username |

### ElastiCache Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `elasticache_node_type` | string | `"cache.t3.micro"` | ElastiCache node type |

### Lambda Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `lambda_timeout` | number | `30` | Lambda function timeout in seconds (3-900) |
| `lambda_memory_size` | number | `512` | Lambda function memory size in MB (128-10240) |

### CloudFront Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cloudfront_price_class` | string | `"PriceClass_100"` | CloudFront price class |

### SQS Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `sqs_visibility_timeout` | number | `300` | SQS visibility timeout in seconds (0-43200) |
| `sqs_message_retention` | number | `1209600` | SQS message retention period in seconds (60-1209600) |

### CloudWatch Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `log_retention_days` | number | `14` | CloudWatch log retention period in days |

### Feature Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_auto_scaling` | bool | `false` | Enable auto scaling for the application |
| `enable_monitoring` | bool | `true` | Enable enhanced monitoring and alerting |
| `enable_backup` | bool | `true` | Enable automated backups |
| `enable_encryption` | bool | `true` | Enable encryption for data at rest |

## Enhanced S3 Configuration

The `s3_buckets` variable allows you to configure multiple S3 buckets with comprehensive options:

```hcl
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
    website_configuration = {
      index_document = "index.html"  # Default: "index.html"
      error_document = "error.html"  # Default: "error.html"
      routing_rules = null  # Default: null
    }
    lifecycle_rules = [
      {
        id = "cleanup-old-versions"
        status = "Enabled"
        noncurrent_version_expiration = {
          noncurrent_days = 30
        }
      }
    ]
    cors_configuration = {
      allowed_headers = ["*"]  # Default: ["*"]
      allowed_methods = ["GET", "HEAD"]  # Default: ["GET", "HEAD"]
      allowed_origins = ["*"]  # Default: ["*"]
      expose_headers = []  # Default: []
      max_age_seconds = 3000  # Default: 3000
    }
    object_ownership = "BucketOwnerPreferred"  # Default: "BucketOwnerPreferred"
    intelligent_tiering = {
      status = "Enabled"  # Default: "Enabled"
      archive_access_tier_days = 90  # Default: 90
      deep_archive_access_tier_days = 180  # Default: 180
    }
    tags = {
      Purpose = "website-hosting"
    }
  }
}
```

## Enhanced CloudFront Configuration

The `cloudfront_distributions` variable provides comprehensive CloudFront customization:

```hcl
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
    aliases = ["example.com"]  # Default: []
    web_acl_id = null  # Default: null
    default_cache_behavior = {
      allowed_methods = ["GET", "HEAD", "OPTIONS"]  # Default: All methods
      cached_methods = ["GET", "HEAD"]  # Default: ["GET", "HEAD"]
      target_origin_id = "S3-website-bucket"  # Default: Website S3 bucket
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
    ordered_cache_behaviors = [
      {
        path_pattern = "/media/*"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-media-bucket"
        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 86400
        max_ttl = 31536000
      }
    ]
    custom_error_responses = [
      {
        error_code = 404
        response_code = "200"
        response_page_path = "/index.html"
      }
    ]
    restrictions = {
      geo_restriction = {
        restriction_type = "none"  # Default: "none"
        locations = []  # Default: []
      }
    }
    viewer_certificate = {
      cloudfront_default_certificate = true  # Default: true
      acm_certificate_arn = null  # Default: null
      ssl_support_method = null  # Default: null
      minimum_protocol_version = null  # Default: null
    }
    tags = {
      Purpose = "website-cdn"
    }
  }
}
```

## Enhanced RDS Configuration

The `rds_instances` variable allows detailed RDS instance configuration:

```hcl
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
    parameter_group_name = null  # Default: null
    option_group_name = null  # Default: null
    monitoring_interval = 0  # Default: 0
    monitoring_role_arn = null  # Default: null
    performance_insights_enabled = false  # Default: false
    performance_insights_retention_period = 7  # Default: 7
    copy_tags_to_snapshot = true  # Default: true
    auto_minor_version_upgrade = true  # Default: true
    allow_major_version_upgrade = false  # Default: false
    apply_immediately = false  # Default: false
    tags = {
      Purpose = "ecommerce-database"
    }
  }
}
```

## Enhanced DynamoDB Configuration

The `dynamodb_tables` variable provides comprehensive DynamoDB table configuration:

```hcl
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
    server_side_encryption = {
      enabled = true  # Default: true
      kms_key_arn = null  # Default: null
    }
    point_in_time_recovery = {
      enabled = true  # Default: true
    }
    attribute = [
      {
        name = "user_id"
        type = "S"
      },
      {
        name = "cart_id"
        type = "S"
      }
    ]
    global_secondary_index = [
      {
        name = "user-index"
        hash_key = "user_id"
        projection_type = "ALL"
      }
    ]
    local_secondary_index = []
    ttl = {
      attribute_name = "expires_at"
      enabled = true
    }
    tags = {
      Purpose = "shopping-carts"
    }
  }
}
```

## Enhanced ElastiCache Configuration

The `elasticache_clusters` variable allows detailed ElastiCache configuration:

```hcl
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
    parameter_group_name = null  # Default: null
    subnet_group_name = null  # Default: null
    security_group_ids = []  # Default: []
    at_rest_encryption_enabled = true  # Default: true
    transit_encryption_enabled = true  # Default: true
    auth_token = null  # Default: null
    kms_key_id = null  # Default: null
    log_delivery_configuration = []  # Default: []
    maintenance_window = null  # Default: null
    snapshot_window = null  # Default: null
    snapshot_retention_limit = 0  # Default: 0
    notification_topic_arn = null  # Default: null
    tags = {
      Purpose = "application-cache"
    }
  }
}
```

## Enhanced Cognito Configuration

The `cognito_user_pools` variable provides comprehensive Cognito configuration:

```hcl
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
    sms_configuration = {
      external_id = "my-ecommerce-app"
      sns_caller_arn = "arn:aws:iam::123456789012:role/cognito-sms-role"
    }
    admin_create_user_config = {
      allow_admin_create_user_only = false  # Default: false
      invite_message_template = {
        email_message = null  # Default: null
        email_subject = null  # Default: null
        sms_message = null  # Default: null
      }
    }
    device_configuration = {
      challenge_required_on_new_device = false  # Default: false
      device_only_remembered_on_user_prompt = false  # Default: false
    }
    user_pool_add_ons = {
      advanced_security_mode = "OFF"  # Default: "OFF"
    }
    username_attributes = []  # Default: []
    username_configuration = {
      case_sensitive = false  # Default: false
    }
    tags = {
      Purpose = "user-authentication"
    }
  }
}
```

## Enhanced SQS Configuration

The `sqs_queues` variable allows detailed SQS queue configuration:

```hcl
sqs_queues = {
  orders = {
    name = "my-ecommerce-app-orders-queue"  # Default: project name + orders-queue
    delay_seconds = 0  # Default: 0
    max_message_size = 262144  # Default: 262144 (256 KB)
    message_retention_seconds = 1209600  # Default: 1209600 (14 days)
    receive_wait_time_seconds = 20  # Default: 20
    visibility_timeout_seconds = 300  # Default: 300
    redrive_policy = null  # Default: null
    redrive_allow_policy = null  # Default: null
    policy = null  # Default: null
    tags = {
      Purpose = "order-processing"
    }
  }
}
```

## Enhanced Lambda Configuration

The `lambda_functions` variable provides comprehensive Lambda function configuration:

```hcl
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
    vpc_config = {
      subnet_ids = []
      security_group_ids = []
    }
    file_system_config = {
      arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:access-point/fsap-12345678"
      local_mount_path = "/mnt/efs"
    }
    image_config = {
      entry_point = []
      command = []
      working_directory = null
    }
    tags = {
      Purpose = "api-handling"
    }
  }
}
```

## E-commerce Platform Configuration

The `ecommerce_platform_config` variable controls e-commerce platform features:

```hcl
ecommerce_platform_config = {
  enable_multi_tenant = false  # Default: false
  enable_marketplace = false  # Default: false
  enable_subscription = false  # Default: false
  enable_digital_products = false  # Default: false
  enable_physical_products = false  # Default: false
  enable_inventory_management = true  # Default: true
  enable_order_management = true  # Default: true
  enable_customer_management = true  # Default: true
  enable_payment_processing = true  # Default: true
  enable_shipping_calculator = true  # Default: true
  enable_tax_calculator = true  # Default: true
  enable_discount_coupons = true  # Default: true
  enable_reviews_ratings = true  # Default: true
  enable_wishlist = true  # Default: true
  enable_notifications = true  # Default: true
  enable_analytics = true  # Default: true
  enable_seo = true  # Default: true
  enable_mobile_app = false  # Default: false
  enable_api_gateway = true  # Default: true
  enable_cdn = true  # Default: true
  enable_caching = true  # Default: true
  enable_monitoring = true  # Default: true
  enable_backup = true  # Default: true
  enable_disaster_recovery = false  # Default: false
}
```

## Payment Processing Configuration

The `payment_processors` variable configures payment processing:

```hcl
payment_processors = {
  stripe = {
    name = "stripe"
    type = "stripe"
    enabled = true  # Default: true
    test_mode = true  # Default: true
    api_key = "sk_test_..."
    secret_key = "sk_test_..."
    webhook_url = "https://api.example.com/webhooks/stripe"
    supported_currencies = ["USD", "EUR"]  # Default: ["USD"]
    supported_payment_methods = ["credit_card", "debit_card"]  # Default: ["credit_card", "debit_card"]
    fraud_detection = {
      enabled = true  # Default: true
      provider = "stripe"  # Default: null
      rules = [
        {
          name = "high-value-transaction"
          type = "amount_threshold"
          threshold = 1000
          action = "review"
        }
      ]
    }
    refund_policy = {
      auto_refund = false  # Default: false
      refund_window_days = 30  # Default: 30
      partial_refunds = true  # Default: true
    }
    tags = {
      Purpose = "payment-processing"
    }
  }
}
```

## Inventory Management Configuration

The `inventory_management` variable configures inventory management:

```hcl
inventory_management = {
  enable_real_time_tracking = true  # Default: true
  enable_low_stock_alerts = true  # Default: true
  enable_auto_reorder = false  # Default: false
  enable_barcode_scanning = false  # Default: false
  enable_serial_number_tracking = false  # Default: false
  enable_lot_tracking = false  # Default: false
  enable_expiry_tracking = false  # Default: false
  enable_multi_location = false  # Default: false
  enable_warehouse_management = false  # Default: false
  low_stock_threshold = 10  # Default: 10
  reorder_point = 5  # Default: 5
  reorder_quantity = 50  # Default: 50
  max_stock_level = 1000  # Default: 1000
  alert_channels = ["email", "sms"]  # Default: ["email", "sms"]
  inventory_valuation_method = "FIFO"  # Default: "FIFO"
}
```

## Order Management Configuration

The `order_management` variable configures order management:

```hcl
order_management = {
  enable_order_tracking = true  # Default: true
  enable_order_notifications = true  # Default: true
  enable_order_history = true  # Default: true
  enable_order_returns = true  # Default: true
  enable_order_cancellations = true  # Default: true
  enable_order_modifications = true  # Default: true
  enable_bulk_orders = false  # Default: false
  enable_subscription_orders = false  # Default: false
  enable_gift_orders = true  # Default: true
  enable_split_orders = false  # Default: false
  order_number_prefix = "ORD"  # Default: "ORD"
  order_number_length = 8  # Default: 8
  order_expiry_hours = 24  # Default: 24
  max_order_value = null  # Default: null
  min_order_value = null  # Default: null
  auto_cancel_unpaid_orders = true  # Default: true
  auto_cancel_timeout_hours = 24  # Default: 24
  return_window_days = 30  # Default: 30
  cancellation_window_hours = 1  # Default: 1
}
```

## Customer Management Configuration

The `customer_management` variable configures customer management:

```hcl
customer_management = {
  enable_customer_registration = true  # Default: true
  enable_guest_checkout = true  # Default: true
  enable_customer_profiles = true  # Default: true
  enable_customer_groups = false  # Default: false
  enable_customer_segments = false  # Default: false
  enable_customer_reviews = true  # Default: true
  enable_customer_support = true  # Default: true
  enable_customer_analytics = true  # Default: true
  require_email_verification = true  # Default: true
  require_phone_verification = false  # Default: false
  enable_two_factor_auth = false  # Default: false
  password_min_length = 8  # Default: 8
  password_require_special_chars = true  # Default: true
  password_require_numbers = true  # Default: true
  password_require_uppercase = true  # Default: true
  session_timeout_minutes = 60  # Default: 60
  max_login_attempts = 5  # Default: 5
  lockout_duration_minutes = 30  # Default: 30
}
```

## Shipping Configuration

The `shipping_config` variable configures shipping:

```hcl
shipping_config = {
  enable_free_shipping = true  # Default: true
  enable_flat_rate_shipping = true  # Default: true
  enable_weight_based_shipping = true  # Default: true
  enable_distance_based_shipping = false  # Default: false
  enable_real_time_shipping = false  # Default: false
  enable_pickup_points = false  # Default: false
  enable_same_day_delivery = false  # Default: false
  enable_next_day_delivery = true  # Default: true
  enable_express_shipping = true  # Default: true
  enable_international_shipping = false  # Default: false
  free_shipping_threshold = 50  # Default: 50
  max_shipping_weight = 50  # Default: 50
  shipping_calculator_provider = "built_in"  # Default: "built_in"
  default_shipping_method = "standard"  # Default: "standard"
  handling_fee = 0  # Default: 0
  insurance_fee = 0  # Default: 0
}
```

## Tax Configuration

The `tax_config` variable configures tax calculation:

```hcl
tax_config = {
  enable_tax_calculation = true  # Default: true
  enable_tax_exemption = false  # Default: false
  enable_tax_invoice = true  # Default: true
  tax_calculator_provider = "built_in"  # Default: "built_in"
  default_tax_rate = 0  # Default: 0
  enable_digital_goods_tax = false  # Default: false
  enable_shipping_tax = true  # Default: true
  enable_handling_tax = true  # Default: true
  tax_included_in_price = false  # Default: false
  tax_rounding_method = "round"  # Default: "round"
  tax_display = "exclusive"  # Default: "exclusive"
}
```

## Discount Configuration

The `discount_config` variable configures discounts:

```hcl
discount_config = {
  enable_coupons = true  # Default: true
  enable_promo_codes = true  # Default: true
  enable_volume_discounts = false  # Default: false
  enable_loyalty_program = false  # Default: false
  enable_referral_program = false  # Default: false
  enable_first_time_discount = true  # Default: true
  enable_birthday_discount = false  # Default: false
  enable_seasonal_discounts = true  # Default: true
  enable_clearance_discounts = true  # Default: true
  max_discount_percentage = 100  # Default: 100
  min_order_value_for_discount = 0  # Default: 0
  allow_multiple_discounts = false  # Default: false
  discount_priority = "highest_first"  # Default: "highest_first"
}
```

## Analytics Configuration

The `analytics_config` variable configures analytics:

```hcl
analytics_config = {
  enable_sales_analytics = true  # Default: true
  enable_customer_analytics = true  # Default: true
  enable_product_analytics = true  # Default: true
  enable_inventory_analytics = true  # Default: true
  enable_marketing_analytics = true  # Default: true
  enable_financial_analytics = true  # Default: true
  enable_real_time_analytics = false  # Default: false
  enable_predictive_analytics = false  # Default: false
  enable_ab_testing = false  # Default: false
  data_retention_days = 365  # Default: 365
  enable_data_export = true  # Default: true
  enable_custom_reports = true  # Default: true
  enable_dashboard = true  # Default: true
  enable_email_reports = false  # Default: false
  report_frequency = "daily"  # Default: "daily"
}
```

## Marketing Configuration

The `marketing_config` variable configures marketing features:

```hcl
marketing_config = {
  enable_email_marketing = true  # Default: true
  enable_sms_marketing = false  # Default: false
  enable_push_notifications = false  # Default: false
  enable_social_media_integration = false  # Default: false
  enable_affiliate_program = false  # Default: false
  enable_referral_program = false  # Default: false
  enable_loyalty_program = false  # Default: false
  enable_gamification = false  # Default: false
  enable_personalization = true  # Default: true
  enable_retargeting = false  # Default: false
  enable_ab_testing = false  # Default: false
  enable_automated_campaigns = false  # Default: false
  enable_segmentation = true  # Default: true
  enable_lead_scoring = false  # Default: false
  enable_conversion_tracking = true  # Default: true
}
```

## Security Configuration

The `security_config` variable configures security features:

```hcl
security_config = {
  enable_ssl = true  # Default: true
  enable_waf = true  # Default: true
  enable_ddos_protection = false  # Default: false
  enable_fraud_detection = true  # Default: true
  enable_pci_compliance = true  # Default: true
  enable_gdpr_compliance = true  # Default: true
  enable_data_encryption = true  # Default: true
  enable_audit_logging = true  # Default: true
  enable_backup_encryption = true  # Default: true
  enable_multi_factor_auth = false  # Default: false
  enable_session_management = true  # Default: true
  enable_rate_limiting = true  # Default: true
  enable_ip_whitelisting = false  # Default: false
  enable_geolocation_restrictions = false  # Default: false
  enable_content_security_policy = true  # Default: true
}
```

## Integration Configuration

The `integrations` variable configures third-party integrations:

```hcl
integrations = {
  shopify = {
    name = "shopify"
    provider = "shopify"
    enabled = true  # Default: true
    api_key = "your-shopify-api-key"
    api_secret = "your-shopify-api-secret"
    webhook_url = "https://api.example.com/webhooks/shopify"
    settings = {
      sync_products = "true"
      sync_orders = "true"
      sync_customers = "true"
    }
    sync_frequency = "hourly"  # Default: "daily"
    auto_sync = true  # Default: true
    tags = {
      Purpose = "ecommerce-integration"
    }
  }
}
```

## Usage Examples

### Minimal Configuration

```hcl
module "ecommerce_platform" {
  source = "path/to/tfm-aws-ecommerce"

  project_name = "my-ecommerce-app"
  environment  = "dev"

  # Use all defaults
  common_tags = {
    Environment = "dev"
    Project     = "my-ecommerce-app"
    ManagedBy   = "terraform"
  }
}
```

### Production Configuration

```hcl
module "ecommerce_platform" {
  source = "path/to/tfm-aws-ecommerce"

  project_name = "my-ecommerce-app"
  environment  = "prod"

  # Enhanced configurations for production
  s3_buckets = {
    website = {
      versioning_enabled = true
      server_side_encryption = {
        sse_algorithm = "AES256"
      }
    }
  }

  rds_instances = {
    main = {
      instance_class = "db.t3.small"
      allocated_storage = 100
      multi_az = true
      deletion_protection = true
    }
  }

  elasticache_clusters = {
    main = {
      node_type = "cache.t3.small"
      automatic_failover_enabled = true
      num_cache_clusters = 2
    }
  }

  lambda_functions = {
    api_handler = {
      timeout = 60
      memory_size = 1024
    }
  }

  common_tags = {
    Environment = "prod"
    Project     = "my-ecommerce-app"
    ManagedBy   = "terraform"
  }
}
```

## Best Practices

1. **Security First**: Always enable encryption and use proper security groups
2. **Environment Separation**: Use different configurations for dev, staging, and prod
3. **Resource Tagging**: Tag all resources for cost tracking and management
4. **Monitoring**: Enable CloudWatch monitoring and set up alerts
5. **Backup Strategy**: Configure automated backups for critical data
6. **Cost Optimization**: Choose appropriate instance types and storage classes
7. **Compliance**: Enable PCI DSS compliance for payment processing
8. **Testing**: Test thoroughly in development before production deployment

## Troubleshooting

### Common Issues

1. **VPC CIDR Conflicts**: Ensure VPC CIDR doesn't conflict with existing networks
2. **Subnet Availability**: Verify sufficient IP addresses in subnets
3. **Security Group Rules**: Check security group rules for proper access
4. **IAM Permissions**: Ensure proper IAM roles and policies
5. **Resource Limits**: Check AWS service limits for your account

### Debugging Steps

1. **Terraform Plan**: Run `terraform plan` to identify configuration issues
2. **CloudWatch Logs**: Check Lambda and application logs
3. **AWS Console**: Verify resource creation in AWS Console
4. **Network Connectivity**: Test connectivity between resources
5. **IAM Permissions**: Verify IAM roles have necessary permissions

### Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the examples directory
- Consult AWS documentation for specific services 