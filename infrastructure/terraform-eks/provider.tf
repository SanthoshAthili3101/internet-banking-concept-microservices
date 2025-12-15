terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Helm is optional now, but safe to keep in required_providers
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }

  # REMOTE BACKEND (Do not change this)
  backend "s3" {
    bucket         = "fintech-state-yeu9sk"
    key            = "eks-cluster/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "fintech-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

# 1. Get Authentication Token
data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

# 2. Configure Kubernetes Provider (We keep this for future use)
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

# 3. HELM PROVIDER REMOVED
# (We removed the provider "helm" block because no resources use it anymore)