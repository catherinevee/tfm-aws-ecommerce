# E-commerce Platform Outputs
# This file defines all outputs from the e-commerce platform module

# VPC and Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.azs
}

# S3 Bucket Outputs
output "website_bucket_name" {
  description = "Name of the website S3 bucket"
  value       = aws_s3_bucket.website.bucket
}

output "website_bucket_arn" {
  description = "ARN of the website S3 bucket"
  value       = aws_s3_bucket.website.arn
}

output "media_bucket_name" {
  description = "Name of the media S3 bucket"
  value       = aws_s3_bucket.media.bucket
}

output "media_bucket_arn" {
  description = "ARN of the media S3 bucket"
  value       = aws_s3_bucket.media.arn
}

output "documents_bucket_name" {
  description = "Name of the documents S3 bucket"
  value       = aws_s3_bucket.documents.bucket
}

output "documents_bucket_arn" {
  description = "ARN of the documents S3 bucket"
  value       = aws_s3_bucket.documents.arn
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "website_url" {
  description = "URL of the website (CloudFront distribution)"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

# RDS Outputs
output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "Master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

# DynamoDB Outputs
output "carts_table_name" {
  description = "Name of the carts DynamoDB table"
  value       = aws_dynamodb_table.carts.name
}

output "carts_table_arn" {
  description = "ARN of the carts DynamoDB table"
  value       = aws_dynamodb_table.carts.arn
}

output "sessions_table_name" {
  description = "Name of the sessions DynamoDB table"
  value       = aws_dynamodb_table.sessions.name
}

output "sessions_table_arn" {
  description = "ARN of the sessions DynamoDB table"
  value       = aws_dynamodb_table.sessions.arn
}

# ElastiCache Outputs
output "elasticache_replication_group_id" {
  description = "ID of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.main.id
}

output "elasticache_primary_endpoint" {
  description = "Primary endpoint of the ElastiCache cluster"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "elasticache_port" {
  description = "Port of the ElastiCache cluster"
  value       = aws_elasticache_replication_group.main.port
}

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "ID of the Cognito user pool"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito user pool"
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_client_id" {
  description = "ID of the Cognito user pool client"
  value       = aws_cognito_user_pool_client.main.id
}

# SQS Outputs
output "orders_queue_url" {
  description = "URL of the orders SQS queue"
  value       = aws_sqs_queue.orders.url
}

output "orders_queue_arn" {
  description = "ARN of the orders SQS queue"
  value       = aws_sqs_queue.orders.arn
}

output "notifications_queue_url" {
  description = "URL of the notifications SQS queue"
  value       = aws_sqs_queue.notifications.url
}

output "notifications_queue_arn" {
  description = "ARN of the notifications SQS queue"
  value       = aws_sqs_queue.notifications.arn
}

# SNS Outputs
output "order_notifications_topic_arn" {
  description = "ARN of the order notifications SNS topic"
  value       = aws_sns_topic.order_notifications.arn
}

output "system_alerts_topic_arn" {
  description = "ARN of the system alerts SNS topic"
  value       = aws_sns_topic.system_alerts.arn
}

# Lambda Outputs
output "api_handler_function_name" {
  description = "Name of the API handler Lambda function"
  value       = aws_lambda_function.api_handler.function_name
}

output "api_handler_function_arn" {
  description = "ARN of the API handler Lambda function"
  value       = aws_lambda_function.api_handler.arn
}

output "order_processor_function_name" {
  description = "Name of the order processor Lambda function"
  value       = aws_lambda_function.order_processor.function_name
}

output "order_processor_function_arn" {
  description = "ARN of the order processor Lambda function"
  value       = aws_lambda_function.order_processor.arn
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "${aws_api_gateway_deployment.main.invoke_url}"
}

# Step Functions Outputs
output "step_functions_state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.order_workflow.arn
}

output "step_functions_state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.order_workflow.name
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "elasticache_security_group_id" {
  description = "ID of the ElastiCache security group"
  value       = aws_security_group.elasticache.id
}

# IAM Role Outputs
output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

output "step_functions_role_arn" {
  description = "ARN of the Step Functions execution role"
  value       = aws_iam_role.step_functions.arn
}

# CloudWatch Log Group Outputs
output "api_handler_log_group_name" {
  description = "Name of the API handler CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_handler.name
}

output "order_processor_log_group_name" {
  description = "Name of the order processor CloudWatch log group"
  value       = aws_cloudwatch_log_group.order_processor.name
}

# Summary Outputs
output "application_endpoints" {
  description = "Summary of application endpoints"
  value = {
    website_url    = "https://${aws_cloudfront_distribution.website.domain_name}"
    api_gateway_url = "${aws_api_gateway_deployment.main.invoke_url}"
    cloudfront_url  = "https://${aws_cloudfront_distribution.website.domain_name}"
  }
}

output "database_connection_info" {
  description = "Database connection information"
  value = {
    endpoint = aws_db_instance.main.endpoint
    port     = aws_db_instance.main.port
    database = aws_db_instance.main.db_name
    username = aws_db_instance.main.username
  }
  sensitive = true
}

output "cache_connection_info" {
  description = "ElastiCache connection information"
  value = {
    endpoint = aws_elasticache_replication_group.main.primary_endpoint_address
    port     = aws_elasticache_replication_group.main.port
  }
}

output "authentication_info" {
  description = "Cognito authentication information"
  value = {
    user_pool_id     = aws_cognito_user_pool.main.id
    user_pool_arn    = aws_cognito_user_pool.main.arn
    client_id        = aws_cognito_user_pool_client.main.id
    user_pool_domain = aws_cognito_user_pool.main.domain
  }
}

output "storage_info" {
  description = "Storage bucket information"
  value = {
    website_bucket    = aws_s3_bucket.website.bucket
    media_bucket      = aws_s3_bucket.media.bucket
    documents_bucket  = aws_s3_bucket.documents.bucket
  }
}

output "queue_info" {
  description = "SQS queue information"
  value = {
    orders_queue_url        = aws_sqs_queue.orders.url
    notifications_queue_url = aws_sqs_queue.notifications.url
  }
}

output "notification_topics" {
  description = "SNS topic information"
  value = {
    order_notifications_topic_arn = aws_sns_topic.order_notifications.arn
    system_alerts_topic_arn       = aws_sns_topic.system_alerts.arn
  }
} 