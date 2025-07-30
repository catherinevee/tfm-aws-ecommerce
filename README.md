# AWS E-commerce Platform Terraform Module

A comprehensive Terraform module for deploying a production-ready e-commerce platform on AWS. This module provides a complete serverless architecture with frontend hosting, API services, database, caching, authentication, and order processing capabilities.

## 🏗️ Architecture Overview

The e-commerce platform is built using a modern serverless architecture with the following components:

### Frontend & API Layer
- **CloudFront + S3**: Static website hosting with global CDN
- **API Gateway + Lambda**: Serverless API endpoints
- **Cognito**: User authentication and authorization

### Backend Services
- **RDS PostgreSQL**: Product catalog and user data storage
- **DynamoDB**: Shopping carts and session data
- **ElastiCache Redis**: Caching layer for improved performance

### Order Processing
- **SQS + Lambda**: Order queue processing
- **Step Functions**: Order workflow orchestration
- **SNS**: Order notifications and system alerts

### Media & Storage
- **S3**: Product images, documents, and static assets
- **CloudFront**: Fast image delivery and caching

## 🚀 Features

- **Serverless Architecture**: Built entirely on AWS serverless services
- **High Availability**: Multi-AZ deployment with automatic failover
- **Security**: VPC isolation, encryption at rest and in transit
- **Scalability**: Auto-scaling capabilities for all components
- **Monitoring**: CloudWatch integration with comprehensive logging
- **Cost Optimization**: Pay-per-use pricing model
- **Compliance Ready**: PCI-DSS compliant architecture

## 📋 Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- AWS Account with access to required services

## 🛠️ Usage

### Basic Example

```hcl
module "ecommerce_platform" {
  source = "path/to/tfm-aws-ecommerce"

  project_name = "my-ecommerce-app"
  environment  = "dev"

  # VPC Configuration
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = 2
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Common Tags
  common_tags = {
    Environment = "dev"
    Project     = "my-ecommerce-app"
    ManagedBy   = "terraform"
  }
}
```

### Production Example

```hcl
module "ecommerce_platform" {
  source = "path/to/tfm-aws-ecommerce"

  project_name = "prod-ecommerce-app"
  environment  = "prod"

  # Multi-AZ Configuration
  availability_zones   = 3
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Production-grade Resources
  rds_instance_class        = "db.r6g.large"
  rds_allocated_storage     = 100
  elasticache_node_type     = "cache.r6g.large"
  lambda_memory_size        = 1024

  # Custom Domain
  domain_name    = "myecommerce.com"
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-certificate-id"

  # Feature Flags
  enable_auto_scaling = true
  enable_monitoring   = true
  enable_backup       = true
  enable_encryption   = true

  common_tags = {
    Environment = "production"
    Project     = "prod-ecommerce-app"
    ManagedBy   = "terraform"
    CostCenter  = "ecommerce-platform"
  }
}
```

## 📖 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project/application | `string` | `"ecommerce-platform"` | no |
| environment | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| availability_zones | Number of availability zones to use | `number` | `2` | no |
| private_subnet_cidrs | CIDR blocks for private subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | no |
| public_subnet_cidrs | CIDR blocks for public subnets | `list(string)` | `["10.0.101.0/24", "10.0.102.0/24"]` | no |
| rds_instance_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| rds_allocated_storage | Allocated storage for RDS instance in GB | `number` | `20` | no |
| rds_max_allocated_storage | Maximum allocated storage for RDS instance in GB | `number` | `100` | no |
| rds_backup_retention_period | Backup retention period in days | `number` | `7` | no |
| elasticache_node_type | ElastiCache node type | `string` | `"cache.t3.micro"` | no |
| lambda_timeout | Lambda function timeout in seconds | `number` | `30` | no |
| lambda_memory_size | Lambda function memory size in MB | `number` | `512` | no |
| cloudfront_price_class | CloudFront price class | `string` | `"PriceClass_100"` | no |
| sqs_visibility_timeout | SQS visibility timeout in seconds | `number` | `300` | no |
| sqs_message_retention | SQS message retention period in seconds | `number` | `1209600` | no |
| log_retention_days | CloudWatch log retention period in days | `number` | `14` | no |
| domain_name | Custom domain name for the application | `string` | `""` | no |
| certificate_arn | ARN of the SSL certificate for custom domain | `string` | `""` | no |
| enable_auto_scaling | Enable auto scaling for the application | `bool` | `false` | no |
| enable_monitoring | Enable enhanced monitoring and alerting | `bool` | `true` | no |
| enable_backup | Enable automated backups | `bool` | `true` | no |
| enable_encryption | Enable encryption for data at rest | `bool` | `true` | no |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| website_url | URL of the e-commerce website |
| api_gateway_url | URL of the API Gateway |
| rds_endpoint | RDS database endpoint |
| elasticache_primary_endpoint | ElastiCache endpoint |
| cognito_user_pool_id | Cognito User Pool ID |
| cognito_user_pool_client_id | Cognito User Pool Client ID |
| step_functions_state_machine_arn | Step Functions state machine ARN |
| application_endpoints | Summary of all application endpoints |
| storage_info | S3 bucket information |
| queue_info | SQS queue information |
| notification_topics | SNS topic information |

## 🔧 Configuration

### Environment-Specific Configurations

The module supports different configurations for development, staging, and production environments:

#### Development Environment
- Single AZ deployment
- Smaller instance types
- Reduced backup retention
- Basic monitoring

#### Production Environment
- Multi-AZ deployment
- Larger instance types
- Extended backup retention
- Enhanced monitoring and alerting
- Custom domain support

### Custom Domain Configuration

To use a custom domain:

1. Register your domain in Route 53 or another DNS provider
2. Request an SSL certificate in AWS Certificate Manager
3. Configure the module with your domain and certificate ARN:

```hcl
domain_name    = "myecommerce.com"
certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-certificate-id"
```

## 🔒 Security

The module implements several security best practices:

- **VPC Isolation**: All resources are deployed within a private VPC
- **Security Groups**: Restrictive security groups for each service
- **Encryption**: Data encrypted at rest and in transit
- **IAM Roles**: Least privilege access for all services
- **Cognito Authentication**: Secure user authentication and authorization

## 📊 Monitoring and Logging

The module provides comprehensive monitoring and logging:

- **CloudWatch Logs**: Centralized logging for all Lambda functions
- **CloudWatch Metrics**: Performance metrics for all services
- **SNS Notifications**: System alerts and order notifications
- **Step Functions**: Workflow monitoring and debugging

## 💰 Cost Optimization

The module is designed for cost optimization:

- **Serverless Services**: Pay only for what you use
- **Auto Scaling**: Automatically scale based on demand
- **Reserved Instances**: Support for RDS reserved instances
- **S3 Lifecycle Policies**: Automatic data lifecycle management

## 🚀 Deployment

### Initial Deployment

1. Clone the repository
2. Navigate to the examples directory
3. Choose your environment (basic or production)
4. Initialize Terraform:
   ```bash
   terraform init
   ```
5. Plan the deployment:
   ```bash
   terraform plan
   ```
6. Apply the configuration:
   ```bash
   terraform apply
   ```

### Updating the Deployment

1. Modify the configuration as needed
2. Plan the changes:
   ```bash
   terraform plan
   ```
3. Apply the changes:
   ```bash
   terraform apply
   ```

### Destroying the Infrastructure

⚠️ **Warning**: This will delete all resources and data!

```bash
terraform destroy
```

## 🧪 Testing

The module includes comprehensive testing:

1. **Terraform Validation**:
   ```bash
   terraform validate
   ```

2. **Terraform Format**:
   ```bash
   terraform fmt
   ```

3. **Terraform Plan**:
   ```bash
   terraform plan
   ```

## 📝 Examples

See the `examples/` directory for complete working examples:

- `examples/basic/`: Basic development deployment
- `examples/production/`: Production-ready deployment

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

1. Check the [Issues](../../issues) page
2. Review the [Documentation](docs/)
3. Contact the development team

## 🔄 Version History

- **v1.0.0**: Initial release with basic e-commerce platform
- **v1.1.0**: Added production configurations and enhanced security
- **v1.2.0**: Added custom domain support and monitoring improvements

## 📚 Additional Resources

- [AWS E-commerce Best Practices](https://aws.amazon.com/solutions/implementations/ecommerce-on-aws/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Serverless Architecture](https://aws.amazon.com/serverless/)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)