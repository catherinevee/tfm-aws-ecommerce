# Database Module

This module manages database resources including RDS, DynamoDB, and ElastiCache.

## Resources Created

- RDS Instance
- DynamoDB Tables
- ElastiCache Redis Cluster
- Subnet Groups
- Parameter Groups

## Usage

```hcl
module "database" {
  source = "./modules/database"

  project_name = "my-ecommerce"
  environment  = "dev"
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnet_ids
}
