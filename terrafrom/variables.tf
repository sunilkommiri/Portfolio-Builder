# terraform/variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # Change to your preferred region
}

variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
  default     = "portfolio-app"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr_block" {
  description = "CIDR block for the public subnet in AZ1."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_az2_cidr_block" {
  description = "CIDR block for the public subnet in AZ2."
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_az1_cidr_block" {
  description = "CIDR block for the private subnet in AZ1."
  type        = string
  default     = "10.0.101.0/24"
}

variable "private_subnet_az2_cidr_block" {
  description = "CIDR block for the private subnet in AZ2."
  type        = string
  default     = "10.0.102.0/24"
}

variable "db_username" {
  description = "Username for the RDS PostgreSQL database."
  type        = string
  default     = "portfolioadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS PostgreSQL database."
  type        = string
  sensitive   = true
  # No default - should be provided via .tfvars file (not committed) or environment variable
  # Example: TF_VAR_db_password="yoursecurepassword"
}

variable "db_instance_class" {
  description = "Instance class for the RDS database."
  type        = string
  default     = "db.t3.micro" # Free Tier eligible (check current AWS Free Tier terms)
}

variable "frontend_container_port" {
  description = "Port the frontend container listens on."
  type        = number
  default     = 80 # Nginx default
}

variable "backend_container_port" {
  description = "Port the backend container listens on."
  type        = number
  default     = 3001 # As set in backend Node.js app
}

variable "desired_task_count" {
  description = "Number of desired tasks for ECS services."
  type        = number
  default     = 1 # Start with 1 for dev/testing
}

variable "frontend_ecr_image_uri" {
  description = "ECR URI for the frontend image (e.g., account_id.dkr.ecr.region.amazonaws.com/repo_name:latest)"
  type        = string
  # No default, this will be dynamic or set at apply time.
  # Jenkins can update the task definition with the specific image tag after a build.
  # For initial apply, you might need to push a placeholder image or use 'latest' if an image exists.
  # Example: default = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/portfolio-builder-frontend:latest"
}

variable "backend_ecr_image_uri" {
  description = "ECR URI for the backend image"
  type        = string
  # Example: default = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/portfolio-builder-backend:latest"
}

# You can add more variables for CPU, Memory for ECS tasks, domain names, ACM certificate ARN, etc.
