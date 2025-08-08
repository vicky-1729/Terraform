provider "aws" {
  region = "us-east-1" # or your preferred region
}

resource "aws_security_group" "allow-all" {
  name        = "allow-all"
  description = "allow - inbound and outbound"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "allow-all-vs"
  }
}


#to check output you need add or mis configure the securty group in the aws
#in terraform just apply      `terraform taint aws_security_group.allow-all`
#after that apply terraform plan is there new changes happend in the security group then it would be deleted while apply .