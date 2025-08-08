terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.98.0"
    }
  }
  # backend "s3" {  
  #   bucket       = "vs-roboshop-infra-dev"  
  #   key          = "roboshop-infra-dev"  
  #   region       = "us-east-1"  
  #   encrypt      = true  
  #   use_lockfile = true  #S3 native locking
  # }  

  # we are using local just for practicse
}

provider "aws"{
    region = "us-east-1"
}