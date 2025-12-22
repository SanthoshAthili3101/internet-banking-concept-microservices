resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"
  depends_on = [
      helm_release.kube_prometheus_stack
    ]
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [<<EOF
controller:
  replicaCount: 2

  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
      service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"

  metrics:
    enabled: true
    serviceMonitor:
      enabled: true

  admissionWebhooks:
    enabled: true

EOF
  ]
}
