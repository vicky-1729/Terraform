terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.98.0"
    }
  }
   backend "s3" {  
    bucket       = "vs-terraform-roboshop"  
    key          = "module-roboshop-prod"  
    region       = "us-east-1"  
    encrypt      = true  
    use_lockfile = true  #S3 native locking
  }  
  
}

