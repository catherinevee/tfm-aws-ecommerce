remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${get_env("TF_VAR_project_name", "ecommerce")}-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "${get_env("TF_VAR_project_name", "ecommerce")}-terraform-locks"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${get_env("AWS_REGION", "us-west-2")}"

  default_tags {
    tags = {
      Environment = "${get_env("TF_VAR_environment", "dev")}"
      Project     = "${get_env("TF_VAR_project_name", "ecommerce")}"
      ManagedBy   = "terragrunt"
    }
  }
}
EOF
}

inputs = {
  project_name = get_env("TF_VAR_project_name", "ecommerce")
  environment  = get_env("TF_VAR_environment", "dev")
  
  # VPC Configuration
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = 2
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Security Configuration
  alb_allowed_cidr_blocks = ["0.0.0.0/0"]  # Should be restricted in production

  # Database Configuration
  db_name     = "ecommerce"
  db_username = "admin"

  # Common Tags
  common_tags = {
    Environment = get_env("TF_VAR_environment", "dev")
    Project     = get_env("TF_VAR_project_name", "ecommerce")
    ManagedBy   = "terragrunt"
  }
}
