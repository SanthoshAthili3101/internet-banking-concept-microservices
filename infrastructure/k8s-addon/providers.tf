provider "aws" {
  region = "ap-south-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.main.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.main.token
}



provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.main.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.main.token
  }
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }

  }

  backend "s3" {
    bucket       = "fintech-terraform-state-yeu9sk"
    key          = "k8s-addons/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:ap-south-1:982081054052:key/1d29119b-fff1-43bb-bcdb-bb3fdbfd0204"
    use_lockfile = true
  }
}
