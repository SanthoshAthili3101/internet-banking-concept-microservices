
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  create_namespace = true
  wait             = true
  timeout          = 600

  values = [<<EOF
server:
  service:
    type: ClusterIP

  metrics:
    enabled: true

controller:
  metrics:
    enabled: true

repoServer:
  metrics:
    enabled: true

applicationSet:
  enabled: true
  metrics:
    enabled: true
EOF
  ]
}

resource "kubernetes_manifest" "internet_banking_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "internet-banking"
      namespace = "argocd"
    }
    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/SanthoshAthili3101/internet-banking-concept-microservices.git"
        path           = "k8s-manifests"
        targetRevision = "HEAD"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "fintech-prod"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        retry = {
          limit = 3
        }
        syncOptions = [
          "CreateNamespace=true",
          "ApplyOutOfSyncOnly=true"
        ]
      }
    }
  }

  depends_on = [helm_release.argocd]
}

