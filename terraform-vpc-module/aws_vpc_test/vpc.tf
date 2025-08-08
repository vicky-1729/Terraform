provider "aws"{
    region = "us-east-1"
}

module "vpc" {
    source = "../aws_vpc"
    project = "roboshop"
    env = "dev"
    public_subnet_cidr = ["10.0.0.0/24","10.0.1.0/24"]
    private_subnet_cidr = ["10.0.2.0/25","10.0.2.128/25"]
    db_subnet_cidr=["10.0.3.0/25","10.0.3.128/25"]
    is_peering_requried = true
}

