# -------------------------------------------------------
# 1. Install Argo CD via Helm
# -------------------------------------------------------
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "6.7.0"
  timeout          = 600
  atomic           = true

  # Expose the UI via a Load Balancer
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  # Use AWS Network Load Balancer (NLB) for production performance
  # NOTE: The double backslashes (\\) are required for Terraform to pass the annotation correctly
  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  # Preserve client source IP for security logging
  set {
    name  = "server.service.externalTrafficPolicy"
    value = "Local"
  }
}

# -------------------------------------------------------
# 2. The GitOps Bootstrap (Production Level)
#    This replaces manually clicking "+ NEW APP" in the UI.
#    It injects the Application configuration as Code.
# -------------------------------------------------------
resource "kubernetes_manifest" "argocd_bootstrap" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "fintech-prod-app"
      namespace = "argocd" # The Application CRD must live where ArgoCD is installed
    }
    spec = {
      project = "default"
      source = {
        # 🚨 CHANGE THIS TO YOUR REPO URL 🚨
        repoURL        = "https://github.com/<YOUR_GITHUB_USERNAME>/<YOUR_REPO_NAME>.git"
        targetRevision = "HEAD"
        path           = "k8s-manifests"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        # This matches the namespace inside your YAML files
        namespace = "fintech-prod" 
      }
      syncPolicy = {
        automated = {
          prune    = true # Delete resources if they are removed from Git
          selfHeal = true # Fix resources if someone manually changes them in the cluster
        }
        syncOptions = ["CreateNamespace=true"] # Auto-create the namespace if missing
      }
    }
  }

  # Wait for ArgoCD to be installed before trying to create this App
  depends_on = [helm_release.argocd]
}

# -------------------------------------------------------
# 3. Outputs (For easy access)
# -------------------------------------------------------
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}
