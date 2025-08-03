variable "project_name" {
  description = "Name of the project/application"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# Lambda Functions
resource "aws_lambda_function" "api_handler" {
  filename         = "lambda/api_handler.zip"
  function_name    = "${var.project_name}-api-handler"
  role            = var.lambda_execution_role_arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30
  memory_size     = 512

  environment {
    variables = var.lambda_environment_variables
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-api-handler"
  })
}

resource "aws_lambda_function" "order_processor" {
  filename         = "lambda/order_processor.zip"
  function_name    = "${var.project_name}-order-processor"
  role            = var.lambda_execution_role_arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 60
  memory_size     = 1024

  environment {
    variables = var.lambda_environment_variables
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
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.api_handler.invoke_arn
}

# Step Functions
resource "aws_sfn_state_machine" "order_workflow" {
  name     = "${var.project_name}-order-workflow"
  role_arn = var.step_functions_role_arn

  definition = jsonencode({
    StartAt = "ProcessOrder"
    States = {
      ProcessOrder = {
        Type = "Task"
        Resource = aws_lambda_function.order_processor.arn
        End = true
      }
    }
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-order-workflow"
  })
}

# Outputs
output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = aws_api_gateway_deployment.main.invoke_url
}

output "lambda_api_handler_arn" {
  description = "ARN of the API handler Lambda function"
  value       = aws_lambda_function.api_handler.arn
}

output "lambda_order_processor_arn" {
  description = "ARN of the order processor Lambda function"
  value       = aws_lambda_function.order_processor.arn
}

output "step_function_arn" {
  description = "ARN of the Step Function state machine"
  value       = aws_sfn_state_machine.order_workflow.arn
}
