resource "aws_db_instance" "fintech_db" {
  identifier        = "fintech-user-db"
  engine            = "mysql"
  engine_version    = "8.0.43"
  instance_class    = "db.t4g.micro"

  allocated_storage = 20
  db_name           = "banking_user_db"

  username          = var.db_username
  password          = var.db_password

  publicly_accessible = true
  skip_final_snapshot = true
  deletion_protection = true

  vpc_security_group_ids = [
    data.aws_security_group.rds_sg.id
  ]

  lifecycle {
    ignore_changes = [
      password,
      max_allocated_storage,
      copy_tags_to_snapshot
    ]
  }
}
