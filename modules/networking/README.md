# Networking Module

This module manages the VPC, subnets, and network-related resources for the e-commerce platform.

## Resources Created

- VPC with public and private subnets
- Internet Gateway
- NAT Gateways
- Route Tables
- Network ACLs
- Security Groups

## Usage

```hcl
module "networking" {
  source = "./modules/networking"

  project_name = "my-ecommerce"
  environment  = "dev"
  vpc_cidr     = "10.0.0.0/16"
  availability_zones = 2
}
