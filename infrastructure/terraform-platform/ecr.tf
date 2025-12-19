# 1. Repository for Core Service
resource "aws_ecr_repository" "core_service" {
  name                 = "fintech/banking-core"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
# 2. Repository for User Service
resource "aws_ecr_repository" "user_service" {
  name                 = "fintech/user-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# 3. Repository for Utility Service
resource "aws_ecr_repository" "utility_service" {
  name                 = "fintech/utility-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# 4. Repository for Fund Transfer Service
resource "aws_ecr_repository" "fund_transfer" {
  name                 = "fintech/fund-transfer"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

