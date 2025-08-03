# Compute Module

This module manages compute resources including Lambda functions, API Gateway, and Step Functions.

## Resources Created

- Lambda Functions
- API Gateway
- Step Functions
- CloudFront Distribution
- IAM Roles and Policies

## Usage

```hcl
module "compute" {
  source = "./modules/compute"

  project_name = "my-ecommerce"
  environment  = "dev"
  vpc_id       = module.networking.vpc_id
}
