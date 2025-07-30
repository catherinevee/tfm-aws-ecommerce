# Production Example Outputs
# This file shows the outputs from the production e-commerce platform deployment

output "website_url" {
  description = "URL of the production e-commerce website"
  value       = module.ecommerce_platform.website_url
}

output "api_gateway_url" {
  description = "URL of the production API Gateway"
  value       = module.ecommerce_platform.api_gateway_url
}

output "database_endpoint" {
  description = "Production RDS database endpoint"
  value       = module.ecommerce_platform.rds_endpoint
}

output "cache_endpoint" {
  description = "Production ElastiCache endpoint"
  value       = module.ecommerce_platform.elasticache_primary_endpoint
}

output "cognito_user_pool_id" {
  description = "Production Cognito User Pool ID"
  value       = module.ecommerce_platform.cognito_user_pool_id
}

output "cognito_client_id" {
  description = "Production Cognito User Pool Client ID"
  value       = module.ecommerce_platform.cognito_user_pool_client_id
}

output "step_functions_arn" {
  description = "Production Step Functions state machine ARN"
  value       = module.ecommerce_platform.step_functions_state_machine_arn
}

output "application_endpoints" {
  description = "All production application endpoints"
  value       = module.ecommerce_platform.application_endpoints
}

output "storage_buckets" {
  description = "Production S3 bucket names"
  value = {
    website_bucket   = module.ecommerce_platform.website_bucket_name
    media_bucket     = module.ecommerce_platform.media_bucket_name
    documents_bucket = module.ecommerce_platform.documents_bucket_name
  }
}

output "queue_urls" {
  description = "Production SQS queue URLs"
  value = {
    orders_queue        = module.ecommerce_platform.orders_queue_url
    notifications_queue = module.ecommerce_platform.notifications_queue_url
  }
}

output "notification_topics" {
  description = "Production SNS topic ARNs"
  value       = module.ecommerce_platform.notification_topics
} 