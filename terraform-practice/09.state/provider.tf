terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }

  backend "s3" {
    bucket         = "vs-terraform-remote-state"
    key            = "terraform_remote_state"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}

