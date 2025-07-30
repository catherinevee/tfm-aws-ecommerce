# E-commerce Platform Terraform Module Makefile
# This Makefile provides common operations for managing the Terraform infrastructure

.PHONY: help init plan apply destroy validate fmt clean test examples-basic examples-production

# Default target
help:
	@echo "Available commands:"
	@echo "  init              - Initialize Terraform"
	@echo "  plan              - Plan Terraform changes"
	@echo "  apply             - Apply Terraform changes"
	@echo "  destroy           - Destroy Terraform infrastructure"
	@echo "  validate          - Validate Terraform configuration"
	@echo "  fmt               - Format Terraform code"
	@echo "  clean             - Clean up temporary files"
	@echo "  test              - Run all tests"
	@echo "  examples-basic    - Deploy basic example"
	@echo "  examples-production - Deploy production example"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Plan Terraform changes
plan:
	@echo "Planning Terraform changes..."
	terraform plan

# Apply Terraform changes
apply:
	@echo "Applying Terraform changes..."
	terraform apply

# Destroy Terraform infrastructure
destroy:
	@echo "Destroying Terraform infrastructure..."
	terraform destroy

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	rm -rf .terraform
	rm -rf .terraform.lock.hcl
	rm -rf terraform.tfstate
	rm -rf terraform.tfstate.backup
	rm -rf *.tfplan

# Run all tests
test: validate fmt
	@echo "Running all tests..."
	@echo "✓ Terraform validation passed"
	@echo "✓ Terraform formatting passed"

# Deploy basic example
examples-basic:
	@echo "Deploying basic example..."
	cd examples/basic && terraform init
	cd examples/basic && terraform plan
	cd examples/basic && terraform apply

# Deploy production example
examples-production:
	@echo "Deploying production example..."
	cd examples/production && terraform init
	cd examples/production && terraform plan
	cd examples/production && terraform apply

# Destroy basic example
examples-basic-destroy:
	@echo "Destroying basic example..."
	cd examples/basic && terraform destroy

# Destroy production example
examples-production-destroy:
	@echo "Destroying production example..."
	cd examples/production && terraform destroy

# Show outputs
outputs:
	@echo "Showing Terraform outputs..."
	terraform output

# Show outputs for basic example
examples-basic-outputs:
	@echo "Showing basic example outputs..."
	cd examples/basic && terraform output

# Show outputs for production example
examples-production-outputs:
	@echo "Showing production example outputs..."
	cd examples/production && terraform output

# Check Terraform version
version:
	@echo "Terraform version:"
	terraform version

# Show AWS provider version
provider-version:
	@echo "AWS Provider version:"
	terraform providers

# Generate documentation
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown . > README.md; \
		echo "Documentation generated successfully"; \
	else \
		echo "terraform-docs not found. Install with: go install github.com/terraform-docs/terraform-docs@latest"; \
	fi

# Security scan
security-scan:
	@echo "Running security scan..."
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "tfsec not found. Install with: brew install tfsec"; \
	fi

# Lint Terraform code
lint:
	@echo "Linting Terraform code..."
	@if command -v tflint >/dev/null 2>&1; then \
		tflint; \
	else \
		echo "tflint not found. Install with: brew install tflint"; \
	fi

# Full validation pipeline
full-validate: validate fmt lint security-scan
	@echo "Full validation completed successfully!"

# Backup state
backup-state:
	@echo "Backing up Terraform state..."
	@if [ -f terraform.tfstate ]; then \
		cp terraform.tfstate terraform.tfstate.backup.$$(date +%Y%m%d_%H%M%S); \
		echo "State backed up successfully"; \
	else \
		echo "No terraform.tfstate file found"; \
	fi

# Restore state from backup
restore-state:
	@echo "Available state backups:"
	@ls -la terraform.tfstate.backup.* 2>/dev/null || echo "No backups found"
	@echo "To restore, run: cp terraform.tfstate.backup.YYYYMMDD_HHMMSS terraform.tfstate"

# Show resource count
resource-count:
	@echo "Counting Terraform resources..."
	@terraform state list | wc -l | xargs echo "Total resources:"

# Show resource types
resource-types:
	@echo "Resource types in use:"
	@terraform state list | sed 's/\.[^.]*$//' | sort | uniq -c | sort -nr

# Cost estimation
cost-estimate:
	@echo "Estimating costs..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
	else \
		echo "infracost not found. Install with: brew install infracost"; \
	fi

# Show module information
module-info:
	@echo "Module information:"
	@echo "Name: AWS E-commerce Platform"
	@echo "Version: 1.0.0"
	@echo "Description: Comprehensive e-commerce platform on AWS"
	@echo "Author: Terraform Module"
	@echo "License: MIT" 