resource "helm_release" "kube_prometheus_stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true
  version    = "58.2.2"

  values = [<<EOF
grafana:
  adminPassword: "admin123"
  service:
    type: LoadBalancer

prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
EOF
  ]

  timeout = 600
}
