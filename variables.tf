# E-commerce Platform Variables
# This file defines all input variables for the e-commerce platform module

variable "project_name" {
  description = "Name of the project/application"
  type        = string
  default     = "ecommerce-platform"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "availability_zones" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zones >= 1 && var.availability_zones <= 4
    error_message = "Availability zones must be between 1 and 4."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All private subnet CIDRs must be valid CIDR blocks."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet CIDRs must be valid CIDR blocks."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "ecommerce-platform"
    ManagedBy   = "terraform"
  }
}

# RDS Variables
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.rds_instance_class))
    error_message = "RDS instance class must be a valid AWS RDS instance type."
  }
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS instance in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.rds_allocated_storage >= 20 && var.rds_allocated_storage <= 65536
    error_message = "RDS allocated storage must be between 20 and 65536 GB."
  }
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for RDS instance in GB"
  type        = number
  default     = 100

  validation {
    condition     = var.rds_max_allocated_storage >= var.rds_allocated_storage
    error_message = "RDS max allocated storage must be greater than or equal to allocated storage."
  }
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.rds_backup_retention_period >= 0 && var.rds_backup_retention_period <= 35
    error_message = "RDS backup retention period must be between 0 and 35 days."
  }
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "ecommerce"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "ecommerce_admin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "Database username must start with a letter and contain only letters, numbers, and underscores."
  }
}

# ElastiCache Variables
variable "elasticache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"

  validation {
    condition     = can(regex("^cache\\.[a-z0-9]+\\.[a-z0-9]+$", var.elasticache_node_type))
    error_message = "ElastiCache node type must be a valid AWS ElastiCache node type."
  }
}

# Lambda Variables
variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.lambda_timeout >= 3 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 3 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512

  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 and 10240 MB."
  }
}

# CloudFront Variables
variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

# SQS Variables
variable "sqs_visibility_timeout" {
  description = "SQS visibility timeout in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.sqs_visibility_timeout >= 0 && var.sqs_visibility_timeout <= 43200
    error_message = "SQS visibility timeout must be between 0 and 43200 seconds."
  }
}

variable "sqs_message_retention" {
  description = "SQS message retention period in seconds"
  type        = number
  default     = 1209600

  validation {
    condition     = var.sqs_message_retention >= 60 && var.sqs_message_retention <= 1209600
    error_message = "SQS message retention must be between 60 and 1209600 seconds."
  }
}

# CloudWatch Variables
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

# Domain Variables (Optional)
variable "domain_name" {
  description = "Custom domain name for the application"
  type        = string
  default     = ""

  validation {
    condition     = var.domain_name == "" || can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])*$", var.domain_name))
    error_message = "Domain name must be a valid domain format."
  }
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for custom domain"
  type        = string
  default     = ""

  validation {
    condition     = var.certificate_arn == "" || can(regex("^arn:aws:acm:[a-z0-9-]+:\\d{12}:certificate/[a-f0-9-]+$", var.certificate_arn))
    error_message = "Certificate ARN must be a valid AWS ACM certificate ARN."
  }
}

# Feature Flags
variable "enable_auto_scaling" {
  description = "Enable auto scaling for the application"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable enhanced monitoring and alerting"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption for data at rest"
  type        = bool
  default     = true
} 

# ==============================================================================
# Enhanced E-commerce Platform Configuration Variables
# ==============================================================================

variable "ecommerce_platform_config" {
  description = "E-commerce platform configuration"
  type = object({
    enable_multi_tenant = optional(bool, false)
    enable_marketplace = optional(bool, false)
    enable_subscription = optional(bool, false)
    enable_digital_products = optional(bool, false)
    enable_physical_products = optional(bool, false)
    enable_inventory_management = optional(bool, true)
    enable_order_management = optional(bool, true)
    enable_customer_management = optional(bool, true)
    enable_payment_processing = optional(bool, true)
    enable_shipping_calculator = optional(bool, true)
    enable_tax_calculator = optional(bool, true)
    enable_discount_coupons = optional(bool, true)
    enable_reviews_ratings = optional(bool, true)
    enable_wishlist = optional(bool, true)
    enable_notifications = optional(bool, true)
    enable_analytics = optional(bool, true)
    enable_seo = optional(bool, true)
    enable_mobile_app = optional(bool, false)
    enable_api_gateway = optional(bool, true)
    enable_cdn = optional(bool, true)
    enable_caching = optional(bool, true)
    enable_monitoring = optional(bool, true)
    enable_backup = optional(bool, true)
    enable_disaster_recovery = optional(bool, false)
  })
  default = {}
}

# ==============================================================================
# Enhanced DynamoDB Configuration Variables
# ==============================================================================

variable "dynamodb_tables" {
  description = "Map of DynamoDB tables to create"
  type = map(object({
    name = string
    billing_mode = optional(string, "PAY_PER_REQUEST")
    read_capacity = optional(number, null)
    write_capacity = optional(number, null)
    hash_key = optional(string, null)
    range_key = optional(string, null)
    stream_enabled = optional(bool, false)
    stream_view_type = optional(string, null)
    server_side_encryption = optional(object({
      enabled = optional(bool, true)
      kms_key_arn = optional(string, null)
    }), {})
    point_in_time_recovery = optional(object({
      enabled = bool
    }), {})
    attribute = optional(list(object({
      name = string
      type = string
    })), [])
    global_secondary_index = optional(list(object({
      name = string
      hash_key = string
      range_key = optional(string, null)
      write_capacity = optional(number, null)
      read_capacity = optional(number, null)
      projection_type = string
      non_key_attributes = optional(list(string), [])
    })), [])
    local_secondary_index = optional(list(object({
      name = string
      range_key = string
      projection_type = string
      non_key_attributes = optional(list(string), [])
    })), [])
    ttl = optional(object({
      attribute_name = string
      enabled = bool
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "dynamodb_global_tables" {
  description = "Map of DynamoDB global tables to create"
  type = map(object({
    name = string
    billing_mode = optional(string, "PAY_PER_REQUEST")
    read_capacity = optional(number, null)
    write_capacity = optional(number, null)
    hash_key = string
    range_key = optional(string, null)
    stream_enabled = bool
    stream_view_type = string
    replica = list(object({
      region_name = string
      kms_key_arn = optional(string, null)
      point_in_time_recovery = optional(object({
        enabled = bool
      }), {})
      tags = optional(map(string), {})
    }))
    attribute = list(object({
      name = string
      type = string
    }))
    global_secondary_index = optional(list(object({
      name = string
      hash_key = string
      range_key = optional(string, null)
      write_capacity = optional(number, null)
      read_capacity = optional(number, null)
      projection_type = string
      non_key_attributes = optional(list(string), [])
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced SQS Configuration Variables
# ==============================================================================

variable "sqs_queues" {
  description = "Map of SQS queues to create"
  type = map(object({
    name = string
    delay_seconds = optional(number, 0)
    max_message_size = optional(number, 262144)
    message_retention_seconds = optional(number, 345600)
    receive_wait_time_seconds = optional(number, 0)
    visibility_timeout_seconds = optional(number, 30)
    redrive_policy = optional(string, null)
    redrive_allow_policy = optional(string, null)
    policy = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "sqs_queue_policies" {
  description = "Map of SQS queue policies to create"
  type = map(object({
    queue_url = string
    policy = string
  }))
  default = {}
}

# ==============================================================================
# Enhanced SNS Configuration Variables
# ==============================================================================

variable "sns_topics" {
  description = "Map of SNS topics to create"
  type = map(object({
    name = string
    display_name = optional(string, null)
    policy = optional(string, null)
    delivery_policy = optional(string, null)
    kms_master_key_id = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "sns_topic_subscriptions" {
  description = "Map of SNS topic subscriptions to create"
  type = map(object({
    topic_arn = string
    protocol = string
    endpoint = string
    endpoint_auto_confirms = optional(bool, null)
    confirmation_timeout_in_minutes = optional(number, null)
    raw_message_delivery = optional(bool, null)
    filter_policy = optional(string, null)
    filter_policy_scope = optional(string, null)
    redrive_policy = optional(string, null)
    subscription_role_arn = optional(string, null)
  }))
  default = {}
}

# ==============================================================================
# Enhanced Payment Processing Configuration Variables
# ==============================================================================

variable "payment_processors" {
  description = "Map of payment processors to configure"
  type = map(object({
    name = string
    type = string
    enabled = optional(bool, true)
    test_mode = optional(bool, true)
    api_key = optional(string, null)
    secret_key = optional(string, null)
    webhook_url = optional(string, null)
    supported_currencies = optional(list(string), ["USD"])
    supported_payment_methods = optional(list(string), ["credit_card", "debit_card"])
    fraud_detection = optional(object({
      enabled = bool
      provider = optional(string, null)
      rules = optional(list(object({
        name = string
        type = string
        threshold = number
        action = string
      })), [])
    }), {})
    refund_policy = optional(object({
      auto_refund = optional(bool, false)
      refund_window_days = optional(number, 30)
      partial_refunds = optional(bool, true)
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "stripe_config" {
  description = "Stripe payment processor configuration"
  type = object({
    enabled = optional(bool, false)
    publishable_key = optional(string, null)
    secret_key = optional(string, null)
    webhook_secret = optional(string, null)
    api_version = optional(string, "2023-10-16")
    supported_currencies = optional(list(string), ["usd"])
    payment_methods = optional(list(string), ["card", "bank_transfer"])
    subscription_products = optional(list(object({
      name = string
      description = optional(string, null)
      unit_amount = number
      currency = optional(string, "usd")
      interval = string
      interval_count = optional(number, 1)
      trial_period_days = optional(number, null)
    })), [])
    webhook_events = optional(list(string), [
      "payment_intent.succeeded",
      "payment_intent.payment_failed",
      "invoice.payment_succeeded",
      "invoice.payment_failed",
      "customer.subscription.created",
      "customer.subscription.updated",
      "customer.subscription.deleted"
    ])
  })
  default = {}
}

variable "paypal_config" {
  description = "PayPal payment processor configuration"
  type = object({
    enabled = optional(bool, false)
    client_id = optional(string, null)
    client_secret = optional(string, null)
    mode = optional(string, "sandbox")
    webhook_id = optional(string, null)
    supported_currencies = optional(list(string), ["USD"])
    payment_methods = optional(list(string), ["paypal", "card"])
    webhook_events = optional(list(string), [
      "PAYMENT.CAPTURE.COMPLETED",
      "PAYMENT.CAPTURE.DENIED",
      "PAYMENT.CAPTURE.PENDING",
      "PAYMENT.CAPTURE.REFUNDED",
      "PAYMENT.CAPTURE.REVERSED"
    ])
  })
  default = {}
}

# ==============================================================================
# Enhanced Inventory Management Configuration Variables
# ==============================================================================

variable "inventory_management" {
  description = "Inventory management configuration"
  type = object({
    enable_real_time_tracking = optional(bool, true)
    enable_low_stock_alerts = optional(bool, true)
    enable_auto_reorder = optional(bool, false)
    enable_barcode_scanning = optional(bool, false)
    enable_serial_number_tracking = optional(bool, false)
    enable_lot_tracking = optional(bool, false)
    enable_expiry_tracking = optional(bool, false)
    enable_multi_location = optional(bool, false)
    enable_warehouse_management = optional(bool, false)
    low_stock_threshold = optional(number, 10)
    reorder_point = optional(number, 5)
    reorder_quantity = optional(number, 50)
    max_stock_level = optional(number, 1000)
    alert_channels = optional(list(string), ["email", "sms"])
    inventory_valuation_method = optional(string, "FIFO")
  })
  default = {}
}

variable "warehouses" {
  description = "Map of warehouses to create"
  type = map(object({
    name = string
    location = object({
      address = string
      city = string
      state = string
      country = string
      postal_code = string
      latitude = optional(number, null)
      longitude = optional(number, null)
    })
    capacity = optional(object({
      total_space = number
      unit = optional(string, "sqft")
      available_space = optional(number, null)
    }), {})
    operating_hours = optional(object({
      monday = optional(object({
        open = string
        close = string
      }), {})
      tuesday = optional(object({
        open = string
        close = string
      }), {})
      wednesday = optional(object({
        open = string
        close = string
      }), {})
      thursday = optional(object({
        open = string
        close = string
      }), {})
      friday = optional(object({
        open = string
        close = string
      }), {})
      saturday = optional(object({
        open = string
        close = string
      }), {})
      sunday = optional(object({
        open = string
        close = string
      }), {})
    }), {})
    contact = optional(object({
      name = string
      email = string
      phone = string
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Order Management Configuration Variables
# ==============================================================================

variable "order_management" {
  description = "Order management configuration"
  type = object({
    enable_order_tracking = optional(bool, true)
    enable_order_notifications = optional(bool, true)
    enable_order_history = optional(bool, true)
    enable_order_returns = optional(bool, true)
    enable_order_cancellations = optional(bool, true)
    enable_order_modifications = optional(bool, true)
    enable_bulk_orders = optional(bool, false)
    enable_subscription_orders = optional(bool, false)
    enable_gift_orders = optional(bool, true)
    enable_split_orders = optional(bool, false)
    order_number_prefix = optional(string, "ORD")
    order_number_length = optional(number, 8)
    order_expiry_hours = optional(number, 24)
    max_order_value = optional(number, null)
    min_order_value = optional(number, null)
    auto_cancel_unpaid_orders = optional(bool, true)
    auto_cancel_timeout_hours = optional(number, 24)
    return_window_days = optional(number, 30)
    cancellation_window_hours = optional(number, 1)
  })
  default = {}
}

variable "order_statuses" {
  description = "Map of order statuses to create"
  type = map(object({
    name = string
    description = optional(string, null)
    color = optional(string, null)
    is_final = optional(bool, false)
    is_cancellable = optional(bool, true)
    is_modifiable = optional(bool, true)
    requires_action = optional(bool, false)
    notification_template = optional(string, null)
    next_statuses = optional(list(string), [])
    auto_transition_conditions = optional(list(object({
      condition = string
      next_status = string
      delay_minutes = optional(number, 0)
    })), [])
  }))
  default = {}
}

# ==============================================================================
# Enhanced Customer Management Configuration Variables
# ==============================================================================

variable "customer_management" {
  description = "Customer management configuration"
  type = object({
    enable_customer_registration = optional(bool, true)
    enable_guest_checkout = optional(bool, true)
    enable_customer_profiles = optional(bool, true)
    enable_customer_groups = optional(bool, false)
    enable_customer_segments = optional(bool, false)
    enable_customer_reviews = optional(bool, true)
    enable_customer_support = optional(bool, true)
    enable_customer_analytics = optional(bool, true)
    require_email_verification = optional(bool, true)
    require_phone_verification = optional(bool, false)
    enable_two_factor_auth = optional(bool, false)
    password_min_length = optional(number, 8)
    password_require_special_chars = optional(bool, true)
    password_require_numbers = optional(bool, true)
    password_require_uppercase = optional(bool, true)
    session_timeout_minutes = optional(number, 60)
    max_login_attempts = optional(number, 5)
    lockout_duration_minutes = optional(number, 30)
  })
  default = {}
}

variable "customer_groups" {
  description = "Map of customer groups to create"
  type = map(object({
    name = string
    description = optional(string, null)
    discount_percentage = optional(number, 0)
    free_shipping = optional(bool, false)
    priority_support = optional(bool, false)
    early_access = optional(bool, false)
    exclusive_offers = optional(bool, false)
    membership_fee = optional(number, 0)
    auto_assign_conditions = optional(list(object({
      field = string
      operator = string
      value = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Shipping Configuration Variables
# ==============================================================================

variable "shipping_config" {
  description = "Shipping configuration"
  type = object({
    enable_free_shipping = optional(bool, true)
    enable_flat_rate_shipping = optional(bool, true)
    enable_weight_based_shipping = optional(bool, true)
    enable_distance_based_shipping = optional(bool, false)
    enable_real_time_shipping = optional(bool, false)
    enable_pickup_points = optional(bool, false)
    enable_same_day_delivery = optional(bool, false)
    enable_next_day_delivery = optional(bool, true)
    enable_express_shipping = optional(bool, true)
    enable_international_shipping = optional(bool, false)
    free_shipping_threshold = optional(number, 50)
    max_shipping_weight = optional(number, 50)
    shipping_calculator_provider = optional(string, "built_in")
    default_shipping_method = optional(string, "standard")
    handling_fee = optional(number, 0)
    insurance_fee = optional(number, 0)
  })
  default = {}
}

variable "shipping_zones" {
  description = "Map of shipping zones to create"
  type = map(object({
    name = string
    countries = optional(list(string), [])
    states = optional(list(string), [])
    cities = optional(list(string), [])
    postal_codes = optional(list(string), [])
    shipping_methods = list(object({
      name = string
      cost = number
      free_shipping_threshold = optional(number, null)
      delivery_time_min = optional(number, null)
      delivery_time_max = optional(number, null)
      weight_limit = optional(number, null)
      enabled = optional(bool, true)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Tax Configuration Variables
# ==============================================================================

variable "tax_config" {
  description = "Tax configuration"
  type = object({
    enable_tax_calculation = optional(bool, true)
    enable_tax_exemption = optional(bool, false)
    enable_tax_invoice = optional(bool, true)
    tax_calculator_provider = optional(string, "built_in")
    default_tax_rate = optional(number, 0)
    enable_digital_goods_tax = optional(bool, false)
    enable_shipping_tax = optional(bool, true)
    enable_handling_tax = optional(bool, true)
    tax_included_in_price = optional(bool, false)
    tax_rounding_method = optional(string, "round")
    tax_display = optional(string, "exclusive")
  })
  default = {}
}

variable "tax_rates" {
  description = "Map of tax rates to create"
  type = map(object({
    name = string
    rate = number
    country = optional(string, null)
    state = optional(string, null)
    city = optional(string, null)
    postal_code = optional(string, null)
    product_categories = optional(list(string), [])
    shipping_taxable = optional(bool, true)
    handling_taxable = optional(bool, true)
    digital_goods_taxable = optional(bool, false)
    enabled = optional(bool, true)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Discount Configuration Variables
# ==============================================================================

variable "discount_config" {
  description = "Discount configuration"
  type = object({
    enable_coupons = optional(bool, true)
    enable_promo_codes = optional(bool, true)
    enable_volume_discounts = optional(bool, false)
    enable_loyalty_program = optional(bool, false)
    enable_referral_program = optional(bool, false)
    enable_first_time_discount = optional(bool, true)
    enable_birthday_discount = optional(bool, false)
    enable_seasonal_discounts = optional(bool, true)
    enable_clearance_discounts = optional(bool, true)
    max_discount_percentage = optional(number, 100)
    min_order_value_for_discount = optional(number, 0)
    allow_multiple_discounts = optional(bool, false)
    discount_priority = optional(string, "highest_first")
  })
  default = {}
}

variable "discount_coupons" {
  description = "Map of discount coupons to create"
  type = map(object({
    code = string
    name = string
    description = optional(string, null)
    discount_type = string
    discount_value = number
    minimum_order_value = optional(number, 0)
    maximum_discount_amount = optional(number, null)
    usage_limit = optional(number, null)
    usage_limit_per_customer = optional(number, 1)
    usage_count = optional(number, 0)
    start_date = optional(string, null)
    end_date = optional(string, null)
    enabled = optional(bool, true)
    applicable_products = optional(list(string), [])
    applicable_categories = optional(list(string), [])
    applicable_customers = optional(list(string), [])
    first_time_customer_only = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Analytics Configuration Variables
# ==============================================================================

variable "analytics_config" {
  description = "Analytics configuration"
  type = object({
    enable_sales_analytics = optional(bool, true)
    enable_customer_analytics = optional(bool, true)
    enable_product_analytics = optional(bool, true)
    enable_inventory_analytics = optional(bool, true)
    enable_marketing_analytics = optional(bool, true)
    enable_financial_analytics = optional(bool, true)
    enable_real_time_analytics = optional(bool, false)
    enable_predictive_analytics = optional(bool, false)
    enable_ab_testing = optional(bool, false)
    data_retention_days = optional(number, 365)
    enable_data_export = optional(bool, true)
    enable_custom_reports = optional(bool, true)
    enable_dashboard = optional(bool, true)
    enable_email_reports = optional(bool, false)
    report_frequency = optional(string, "daily")
  })
  default = {}
}

variable "analytics_events" {
  description = "Map of analytics events to track"
  type = map(object({
    name = string
    description = optional(string, null)
    enabled = optional(bool, true)
    properties = optional(list(object({
      name = string
      type = string
      required = optional(bool, false)
      default_value = optional(string, null)
    })), [])
    triggers = optional(list(string), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Marketing Configuration Variables
# ==============================================================================

variable "marketing_config" {
  description = "Marketing configuration"
  type = object({
    enable_email_marketing = optional(bool, true)
    enable_sms_marketing = optional(bool, false)
    enable_push_notifications = optional(bool, false)
    enable_social_media_integration = optional(bool, false)
    enable_affiliate_program = optional(bool, false)
    enable_referral_program = optional(bool, false)
    enable_loyalty_program = optional(bool, false)
    enable_gamification = optional(bool, false)
    enable_personalization = optional(bool, true)
    enable_retargeting = optional(bool, false)
    enable_ab_testing = optional(bool, false)
    enable_automated_campaigns = optional(bool, false)
    enable_segmentation = optional(bool, true)
    enable_lead_scoring = optional(bool, false)
    enable_conversion_tracking = optional(bool, true)
  })
  default = {}
}

variable "email_campaigns" {
  description = "Map of email campaigns to create"
  type = map(object({
    name = string
    subject = string
    template = string
    audience = object({
      type = string
      criteria = optional(list(object({
        field = string
        operator = string
        value = string
      })), [])
    })
    schedule = optional(object({
      type = string
      date = optional(string, null)
      time = optional(string, null)
      frequency = optional(string, null)
      day_of_week = optional(string, null)
      day_of_month = optional(number, null)
    }), {})
    settings = optional(object({
      from_name = string
      from_email = string
      reply_to = optional(string, null)
      track_opens = optional(bool, true)
      track_clicks = optional(bool, true)
      enable_unsubscribe = optional(bool, true)
    }), {})
    enabled = optional(bool, true)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Security Configuration Variables
# ==============================================================================

variable "security_config" {
  description = "Security configuration"
  type = object({
    enable_ssl = optional(bool, true)
    enable_waf = optional(bool, true)
    enable_ddos_protection = optional(bool, false)
    enable_fraud_detection = optional(bool, true)
    enable_pci_compliance = optional(bool, true)
    enable_gdpr_compliance = optional(bool, true)
    enable_data_encryption = optional(bool, true)
    enable_audit_logging = optional(bool, true)
    enable_backup_encryption = optional(bool, true)
    enable_multi_factor_auth = optional(bool, false)
    enable_session_management = optional(bool, true)
    enable_rate_limiting = optional(bool, true)
    enable_ip_whitelisting = optional(bool, false)
    enable_geolocation_restrictions = optional(bool, false)
    enable_content_security_policy = optional(bool, true)
  })
  default = {}
}

variable "security_rules" {
  description = "Map of security rules to create"
  type = map(object({
    name = string
    type = string
    description = optional(string, null)
    enabled = optional(bool, true)
    priority = optional(number, 100)
    conditions = list(object({
      field = string
      operator = string
      value = string
    }))
    actions = list(object({
      type = string
      value = string
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced S3 Configuration Variables
# ==============================================================================

variable "s3_buckets" {
  description = "Map of S3 bucket configurations"
  type = map(object({
    force_destroy = optional(bool, false)
    versioning_enabled = optional(bool, false)
    mfa_delete = optional(bool, false)
    server_side_encryption = optional(object({
      sse_algorithm = optional(string, "AES256")
      kms_master_key_id = optional(string, null)
      bucket_key_enabled = optional(bool, false)
    }), {})
    public_access_block = optional(object({
      block_public_acls = optional(bool, true)
      block_public_policy = optional(bool, true)
      ignore_public_acls = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }), {})
    website_configuration = optional(object({
      index_document = optional(string, "index.html")
      error_document = optional(string, "error.html")
      routing_rules = optional(string, null)
    }), {})
    lifecycle_rules = optional(list(object({
      id = string
      status = string
      enabled = optional(bool, true)
      abort_incomplete_multipart_upload_days = optional(number, null)
      expiration = optional(object({
        days = optional(number, null)
        date = optional(string, null)
        expired_object_delete_marker = optional(bool, null)
      }), {})
      noncurrent_version_expiration = optional(object({
        noncurrent_days = number
      }), {})
      transitions = optional(list(object({
        days = number
        storage_class = string
      })), [])
      noncurrent_version_transitions = optional(list(object({
        noncurrent_days = number
        storage_class = string
      })), [])
    })), [])
    cors_configuration = optional(object({
      allowed_headers = optional(list(string), ["*"])
      allowed_methods = optional(list(string), ["GET", "HEAD"])
      allowed_origins = optional(list(string), ["*"])
      expose_headers = optional(list(string), [])
      max_age_seconds = optional(number, 3000)
    }), {})
    object_ownership = optional(string, "BucketOwnerPreferred")
    intelligent_tiering = optional(object({
      status = optional(string, "Enabled")
      archive_access_tier_days = optional(number, 90)
      deep_archive_access_tier_days = optional(number, 180)
    }), {})
    inventory_configuration = optional(object({
      destination_bucket = string
      destination_prefix = optional(string, null)
      included_object_versions = optional(string, "Current")
      schedule = optional(object({
        frequency = optional(string, "Weekly")
      }), {})
    }), {})
    object_lock_configuration = optional(object({
      object_lock_enabled = optional(string, "Enabled")
      rule = optional(object({
        default_retention = optional(object({
          mode = string
          days = optional(number, null)
          years = optional(number, null)
        }), {})
      }), {})
    }), {})
    replication_configuration = optional(object({
      role = string
      rules = list(object({
        id = string
        status = string
        priority = optional(number, null)
        destination = object({
          bucket = string
          storage_class = optional(string, null)
          replica_kms_key_id = optional(string, null)
          access_control_translation = optional(object({
            owner = string
          }), {})
        })
        source_selection_criteria = optional(object({
          sse_kms_encrypted_objects = optional(object({
            status = string
          }), {})
        }), {})
      }))
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CloudFront Configuration Variables
# ==============================================================================

variable "cloudfront_distributions" {
  description = "Map of CloudFront distribution configurations"
  type = map(object({
    enabled = optional(bool, true)
    is_ipv6_enabled = optional(bool, true)
    default_root_object = optional(string, "index.html")
    price_class = optional(string, "PriceClass_100")
    comment = optional(string, null)
    retain_on_delete = optional(bool, false)
    wait_for_deployment = optional(bool, true)
    http_version = optional(string, "http2")
    aliases = optional(list(string), [])
    web_acl_id = optional(string, null)
    default_cache_behavior = optional(object({
      allowed_methods = optional(list(string), ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
      cached_methods = optional(list(string), ["GET", "HEAD"])
      target_origin_id = optional(string, null)
      forwarded_values = optional(object({
        query_string = optional(bool, false)
        headers = optional(list(string), [])
        cookies = optional(object({
          forward = optional(string, "none")
          whitelisted_names = optional(list(string), [])
        }), {})
      }), {})
      viewer_protocol_policy = optional(string, "redirect-to-https")
      min_ttl = optional(number, 0)
      default_ttl = optional(number, 3600)
      max_ttl = optional(number, 86400)
      compress = optional(bool, true)
    }), {})
    ordered_cache_behaviors = optional(list(object({
      path_pattern = string
      allowed_methods = optional(list(string), ["GET", "HEAD"])
      cached_methods = optional(list(string), ["GET", "HEAD"])
      target_origin_id = optional(string, null)
      forwarded_values = optional(object({
        query_string = optional(bool, false)
        headers = optional(list(string), [])
        cookies = optional(object({
          forward = optional(string, "none")
          whitelisted_names = optional(list(string), [])
        }), {})
      }), {})
      viewer_protocol_policy = optional(string, "redirect-to-https")
      min_ttl = optional(number, 0)
      default_ttl = optional(number, 3600)
      max_ttl = optional(number, 86400)
      compress = optional(bool, true)
    })), [])
    custom_error_responses = optional(list(object({
      error_code = number
      response_code = optional(string, null)
      response_page_path = optional(string, null)
      error_caching_min_ttl = optional(number, null)
    })), [])
    restrictions = optional(object({
      geo_restriction = optional(object({
        restriction_type = optional(string, "none")
        locations = optional(list(string), [])
      }), {})
    }), {})
    viewer_certificate = optional(object({
      cloudfront_default_certificate = optional(bool, true)
      acm_certificate_arn = optional(string, null)
      ssl_support_method = optional(string, null)
      minimum_protocol_version = optional(string, null)
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced RDS Configuration Variables
# ==============================================================================

variable "rds_instances" {
  description = "Map of RDS instance configurations"
  type = map(object({
    engine = optional(string, "postgres")
    engine_version = optional(string, "14")
    instance_class = optional(string, null)
    allocated_storage = optional(number, null)
    max_allocated_storage = optional(number, null)
    storage_type = optional(string, "gp2")
    storage_encrypted = optional(bool, true)
    db_name = optional(string, null)
    username = optional(string, null)
    backup_retention_period = optional(number, null)
    backup_window = optional(string, "03:00-04:00")
    maintenance_window = optional(string, "sun:04:00-sun:05:00")
    skip_final_snapshot = optional(bool, null)
    deletion_protection = optional(bool, null)
    multi_az = optional(bool, false)
    publicly_accessible = optional(bool, false)
    port = optional(number, 5432)
    parameter_group_name = optional(string, null)
    option_group_name = optional(string, null)
    monitoring_interval = optional(number, 0)
    monitoring_role_arn = optional(string, null)
    performance_insights_enabled = optional(bool, false)
    performance_insights_retention_period = optional(number, 7)
    copy_tags_to_snapshot = optional(bool, true)
    auto_minor_version_upgrade = optional(bool, true)
    allow_major_version_upgrade = optional(bool, false)
    apply_immediately = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced ElastiCache Configuration Variables
# ==============================================================================

variable "elasticache_clusters" {
  description = "Map of ElastiCache cluster configurations"
  type = map(object({
    replication_group_id = optional(string, null)
    description = optional(string, null)
    node_type = optional(string, null)
    port = optional(number, 6379)
    automatic_failover_enabled = optional(bool, null)
    num_cache_clusters = optional(number, null)
    engine = optional(string, "redis")
    engine_version = optional(string, "7.0")
    parameter_group_name = optional(string, null)
    subnet_group_name = optional(string, null)
    security_group_ids = optional(list(string), [])
    at_rest_encryption_enabled = optional(bool, true)
    transit_encryption_enabled = optional(bool, true)
    auth_token = optional(string, null)
    kms_key_id = optional(string, null)
    log_delivery_configuration = optional(list(object({
      destination = string
      destination_type = string
      log_format = string
      log_type = string
    })), [])
    maintenance_window = optional(string, null)
    snapshot_window = optional(string, null)
    snapshot_retention_limit = optional(number, 0)
    notification_topic_arn = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Cognito Configuration Variables
# ==============================================================================

variable "cognito_user_pools" {
  description = "Map of Cognito user pool configurations"
  type = map(object({
    name = optional(string, null)
    password_policy = optional(object({
      minimum_length = optional(number, 8)
      require_lowercase = optional(bool, true)
      require_numbers = optional(bool, true)
      require_symbols = optional(bool, true)
      require_uppercase = optional(bool, true)
      temporary_password_validity_days = optional(number, 7)
    }), {})
    auto_verified_attributes = optional(list(string), ["email"])
    verification_message_template = optional(object({
      default_email_option = optional(string, "CONFIRM_WITH_CODE")
      email_subject = optional(string, null)
      email_message = optional(string, null)
      sms_message = optional(string, null)
    }), {})
    email_configuration = optional(object({
      email_sending_account = optional(string, "COGNITO_DEFAULT")
      from_email_address = optional(string, null)
      reply_to_email_address = optional(string, null)
      source_arn = optional(string, null)
    }), {})
    sms_configuration = optional(object({
      external_id = string
      sns_caller_arn = string
    }), {})
    admin_create_user_config = optional(object({
      allow_admin_create_user_only = optional(bool, false)
      invite_message_template = optional(object({
        email_message = optional(string, null)
        email_subject = optional(string, null)
        sms_message = optional(string, null)
      }), {})
    }), {})
    device_configuration = optional(object({
      challenge_required_on_new_device = optional(bool, false)
      device_only_remembered_on_user_prompt = optional(bool, false)
    }), {})
    user_pool_add_ons = optional(object({
      advanced_security_mode = optional(string, "OFF")
    }), {})
    username_attributes = optional(list(string), [])
    username_configuration = optional(object({
      case_sensitive = optional(bool, false)
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Lambda Configuration Variables
# ==============================================================================

variable "lambda_functions" {
  description = "Map of Lambda function configurations"
  type = map(object({
    filename = optional(string, null)
    function_name = optional(string, null)
    handler = optional(string, "index.handler")
    runtime = optional(string, "nodejs18.x")
    timeout = optional(number, 30)
    memory_size = optional(number, 512)
    description = optional(string, null)
    reserved_concurrent_executions = optional(number, null)
    publish = optional(bool, false)
    layers = optional(list(string), [])
    environment = optional(object({
      variables = optional(map(string), {})
    }), {})
    vpc_config = optional(object({
      subnet_ids = list(string)
      security_group_ids = list(string)
    }), {})
    file_system_config = optional(object({
      arn = string
      local_mount_path = string
    }), {})
    image_config = optional(object({
      entry_point = optional(list(string), [])
      command = optional(list(string), [])
      working_directory = optional(string, null)
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Integration Configuration Variables
# ==============================================================================

variable "integrations" {
  description = "Map of third-party integrations to configure"
  type = map(object({
    name = string
    provider = string
    enabled = optional(bool, true)
    api_key = optional(string, null)
    api_secret = optional(string, null)
    webhook_url = optional(string, null)
    settings = optional(map(string), {})
    sync_frequency = optional(string, "daily")
    auto_sync = optional(bool, true)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "webhook_endpoints" {
  description = "Map of webhook endpoints to create"
  type = map(object({
    name = string
    url = string
    events = list(string)
    secret = optional(string, null)
    enabled = optional(bool, true)
    retry_count = optional(number, 3)
    timeout_seconds = optional(number, 30)
    headers = optional(map(string), {})
    tags = optional(map(string), {})
  }))
  default = {}
} 