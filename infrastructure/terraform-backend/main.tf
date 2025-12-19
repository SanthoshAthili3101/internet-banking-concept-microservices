terraform {
  required_version = ">= 1.5.0"

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

############################################
# Generate random suffix for unique bucket
############################################
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

############################################
# KMS Key for Terraform state encryption
############################################
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for encrypting Terraform state files"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "terraform_state_alias" {
  name          = "alias/terraform-state-key"
  target_key_id = aws_kms_key.terraform_state.key_id
}

############################################
# S3 Bucket for Terraform Remote State
############################################
resource "aws_s3_bucket" "terraform_state" {
  bucket = "fintech-terraform-state-${random_string.suffix.result}"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "terraform-remote-state"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

############################################
# Enable Versioning (mandatory for state safety)
############################################
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# Server-side Encryption with KMS
############################################
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
  }
}

############################################
# Block all public access (security best practice)
############################################
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# Outputs (use these in backend config)
############################################
output "terraform_state_bucket_name" {
  description = "S3 bucket name used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_kms_key_arn" {
  description = "KMS key ARN used to encrypt Terraform state"
  value       = aws_kms_key.terraform_state.arn
}

output "terraform_state_kms_key_id" {
  description = "KMS key ID used for Terraform state encryption"
  value       = aws_kms_key.terraform_state.key_id
}

output "terraform_state_region" {
  description = "AWS region of the Terraform state bucket"
  value       = "ap-south-1"
}

