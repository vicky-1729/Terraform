module "vpc" {
    source = "../modules/vpc"
    
    # Required Variables
    project              = var.project
    environment          = var.environment
    cidr_blocks          = var.vpc_cidr
    public_subnet_cidrs  = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    db_subnet_cidrs      = var.db_subnet_cidrs
    
    # Optional Tags
    vpc_tags = var.vpc_tags
    igw_tags = var.igw_tags
    eip_tags = var.eip_tags
}