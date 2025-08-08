terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.98.0"
        }
    }
    
    # backend "s3" {  
    #   bucket       = "vs-roboshop-infra-dev"  
    #   key          = "bastion/terraform.tfstate"  
    #   region       = "us-east-1"  
    #   encrypt      = true  
    #   use_lockfile = true  #S3 native locking
    # }  

    # Using local backend for practice
}

provider "aws" {
    region = "us-east-1"
}
