resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "fintech/prod/db-credentials"
  description             = "Database credentials for Fintech App"
  recovery_window_in_days = 0 
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "db_credentials_val" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id

  # Terraform automatically grabs the address from step 1 and password from variables
  secret_string = jsonencode({
    db-host     = aws_db_instance.fintech_db.address
    db-username = var.db_username
    db-password = var.db_password
  })
}