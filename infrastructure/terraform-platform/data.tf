data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "rds_sg" {
  id = "sg-00b3cfcf2180d4499"
}