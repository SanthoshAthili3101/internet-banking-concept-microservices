data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "fintech-terraform-state-yeu9sk"
    key    = "eks/dev/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "aws_eks_cluster" "main" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "kubernetes_secret_v1" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}
