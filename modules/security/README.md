# Security Module

This module manages security-related resources including Cognito, IAM, and KMS.

## Resources Created

- Cognito User Pool
- IAM Roles and Policies
- KMS Keys
- Security Groups
- S3 Bucket Policies

## Usage

```hcl
module "security" {
  source = "./modules/security"

  project_name = "my-ecommerce"
  environment  = "dev"
  vpc_id       = module.networking.vpc_id
}
