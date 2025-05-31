# terraform/backend.tf
# Configure S3 backend for remote state storage.
# Create the S3 bucket and DynamoDB table manually or via a separate Terraform config first.

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket-name-unique" # <<< REPLACE with your unique S3 bucket name
#     key            = "portfolio-app/terraform.tfstate"         # Path to state file in the bucket
#     region         = "us-east-1"                               # <<< REPLACE with your S3 bucket region
#     encrypt        = true                                      # Encrypt state file
#     dynamodb_table = "your-terraform-state-lock-table"       # <<< REPLACE (Optional: for state locking)
#   }
# }

# If you are starting without a remote backend and want to initialize locally first,
# you can comment out the above block. Later, you can migrate to S3.
