# terraform/versions.tf

terraform {
  required_version = ">= 1.5.0" # Specify a minimum Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40" # Check for the latest stable version and update accordingly
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  # You can add default_tags here if desired
  # default_tags {
  #   tags = {
  #     Environment = var.environment
  #     Project     = var.project_name
  #   }
  # }
}
