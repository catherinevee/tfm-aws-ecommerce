variables {
  project_name = "test-ecommerce"
  environment  = "dev"
  vpc_cidr     = "10.0.0.0/16"
  availability_zones = 2
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
}

run "verify_vpc_creation" {
  command = plan

  assert {
    condition     = module.vpc.vpc_id != ""
    error_message = "VPC was not created successfully"
  }

  assert {
    condition     = length(module.vpc.private_subnets) == 2
    error_message = "Expected 2 private subnets"
  }

  assert {
    condition     = length(module.vpc.public_subnets) == 2
    error_message = "Expected 2 public subnets"
  }
}

run "verify_security_groups" {
  command = plan

  assert {
    condition     = aws_security_group.alb.vpc_id != ""
    error_message = "ALB security group was not created"
  }

  assert {
    condition     = aws_security_group.rds.vpc_id != ""
    error_message = "RDS security group was not created"
  }
}

run "verify_s3_buckets" {
  command = plan

  assert {
    condition     = aws_s3_bucket.website.bucket != ""
    error_message = "Website bucket was not created"
  }

  assert {
    condition     = aws_s3_bucket.media.bucket != ""
    error_message = "Media bucket was not created"
  }
}
