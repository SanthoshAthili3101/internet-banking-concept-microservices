# Output the Repository URLs so you can copy them easily
output "ecr_urls" {
  value = {
    core          = aws_ecr_repository.core_service.repository_url
    user          = aws_ecr_repository.user_service.repository_url
    utility       = aws_ecr_repository.utility_service.repository_url
    fund_transfer = aws_ecr_repository.fund_transfer.repository_url
  }
}


output "argocd_url" {
  value       = try(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname, "Waiting for Load Balancer...")
  description = "The public URL to access ArgoCD"
}

output "argocd_password_command" {
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode"
  description = "Run this to get the admin password"
}