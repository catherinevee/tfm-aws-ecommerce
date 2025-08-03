include {
  path = find_in_parent_folders()
}

inputs = {
  environment = "prod"
  
  # Override VPC Configuration for prod
  vpc_cidr             = "10.1.0.0/16"
  availability_zones   = 3
  private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  
  # Override Database Configuration for prod
  db_instance_class = "db.r5.large"
  db_allocated_storage = 100
  db_max_allocated_storage = 1000
  
  # Override ElastiCache Configuration for prod
  elasticache_node_type = "cache.r5.large"
  
  # Common Tags
  common_tags = {
    Environment = "prod"
    Project     = get_env("TF_VAR_project_name", "ecommerce")
    ManagedBy   = "terragrunt"
  }
}
