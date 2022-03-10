data "aws_ami" "ami" {
#  executable_users = ["self"]
  most_recent      = true
  name_regex       = "base-with-ansible"
  owners           = ["self"]
}

## aws s3 backend configuration -- to access data from vpc statefile and outputs block
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sa-newbuck-1"
    key    = "vpc/${var.ENV}/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "sa-newbuck-1"
    key    = "mutable/alb/${var.ENV}/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_secretsmanager_secret" "password" {
  name = "pswd"
}

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = data.aws_secretsmanager_secret.password.id
}

