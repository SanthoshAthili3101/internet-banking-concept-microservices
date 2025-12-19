variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default   = "FintechSecure123!"
  sensitive = true
}

variable "db_name" {
  default = "banking_user_db"
}