# Output the Repository URLs so you can copy them easily
output "ecr_urls" {
  value = {
    core          = aws_ecr_repository.core_service.repository_url
    user          = aws_ecr_repository.user_service.repository_url
    utility       = aws_ecr_repository.utility_service.repository_url
    fund_transfer = aws_ecr_repository.fund_transfer.repository_url
  }
}

