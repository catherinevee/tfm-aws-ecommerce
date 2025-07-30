# Test Outputs
# This file shows the outputs from the test deployment

output "test_website_url" {
  description = "Test website URL"
  value       = module.ecommerce_platform_test.website_url
}

output "test_api_gateway_url" {
  description = "Test API Gateway URL"
  value       = module.ecommerce_platform_test.api_gateway_url
}

output "test_vpc_id" {
  description = "Test VPC ID"
  value       = module.ecommerce_platform_test.vpc_id
}

output "test_rds_endpoint" {
  description = "Test RDS endpoint"
  value       = module.ecommerce_platform_test.rds_endpoint
}

output "test_elasticache_endpoint" {
  description = "Test ElastiCache endpoint"
  value       = module.ecommerce_platform_test.elasticache_primary_endpoint
}

output "test_cognito_user_pool_id" {
  description = "Test Cognito User Pool ID"
  value       = module.ecommerce_platform_test.cognito_user_pool_id
}

output "test_application_endpoints" {
  description = "Test application endpoints"
  value       = module.ecommerce_platform_test.application_endpoints
} 