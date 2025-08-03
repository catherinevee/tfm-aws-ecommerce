include {
  path = find_in_parent_folders()
}

inputs = {
  environment = "dev"
  
  # Override VPC Configuration for dev
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = 2
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # Override Database Configuration for dev
  db_instance_class = "db.t3.small"
  db_allocated_storage = 20
  db_max_allocated_storage = 100
  
  # Override ElastiCache Configuration for dev
  elasticache_node_type = "cache.t3.micro"
  
  # Common Tags
  common_tags = {
    Environment = "dev"
    Project     = get_env("TF_VAR_project_name", "ecommerce")
    ManagedBy   = "terragrunt"
  }
}
