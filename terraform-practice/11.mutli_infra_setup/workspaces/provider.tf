terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3"{
    bucket      = "vs-terraform-roboshop"
    key         = "workspaces"
    region      = "us-east-1"
    encrypt     = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}


