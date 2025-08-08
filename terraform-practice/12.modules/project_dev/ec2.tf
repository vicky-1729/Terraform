provider "aws" {
  region = "us-east-1" # or your preferred region
  }

module "ec2" {
    source = "../aws_instance"
    instance_tags = var.tags
    sg_ids = var.security_group_ids
    #instance_type = var.instance_type
}