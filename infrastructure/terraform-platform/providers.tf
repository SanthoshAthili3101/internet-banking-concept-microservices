terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "fintech-terraform-state-yeu9sk"
    key          = "platform/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:ap-south-1:982081054052:key/1d29119b-fff1-43bb-bcdb-bb3fdbfd0204"
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}
