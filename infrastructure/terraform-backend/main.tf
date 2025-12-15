# infrastructure/terraform-backend/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# 1. Generate a random suffix for unique bucket name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# 2. KMS Key (To encrypt the state file securely)
resource "aws_kms_key" "terraform_state_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# 3. S3 Bucket (The Storage)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "fintech-state-${random_string.suffix.result}" # Unique Name
  
  # Prevent accidental deletion of this critical bucket
  lifecycle {
    prevent_destroy = true
  }
}

# 4. Enable Versioning (Crucial for rollback if state gets corrupted)
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 5. Encrypt Bucket with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state_key.arn
    }
  }
}

# 6. Public Access Block (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 7. DynamoDB Table (The Lock Mechanism)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "fintech-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# 8. OUTPUTS (Save these!)
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}