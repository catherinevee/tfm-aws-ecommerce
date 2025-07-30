# Basic Example Outputs
# This file shows the outputs from the basic e-commerce platform deployment

output "website_url" {
  description = "URL of the e-commerce website"
  value       = module.ecommerce_platform.website_url
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.ecommerce_platform.api_gateway_url
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.ecommerce_platform.rds_endpoint
}

output "cache_endpoint" {
  description = "ElastiCache endpoint"
  value       = module.ecommerce_platform.elasticache_primary_endpoint
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.ecommerce_platform.cognito_user_pool_id
}

output "cognito_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.ecommerce_platform.cognito_user_pool_client_id
}

output "application_endpoints" {
  description = "All application endpoints"
  value       = module.ecommerce_platform.application_endpoints
}

output "storage_buckets" {
  description = "S3 bucket names"
  value = {
    website_bucket   = module.ecommerce_platform.website_bucket_name
    media_bucket     = module.ecommerce_platform.media_bucket_name
    documents_bucket = module.ecommerce_platform.documents_bucket_name
  }
} 