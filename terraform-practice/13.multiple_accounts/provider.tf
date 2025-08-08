terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}
provider "aws"{
    region = "us-east-1"
    alias = "dev"
    profile = "dev"
}
provider "aws"{
    region = "us-east-1"
    alias = "prod"
    profile = "prod"
}