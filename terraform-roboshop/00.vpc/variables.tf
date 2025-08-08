# Project and Environment Configuration
variable "project" {
    type        = string
    description = "Project name for resource naming and tagging"
    default     = "roboshop"
}

variable "environment" {
    type        = string
    description = "Environment name (dev, staging, prod)"
    default     = "dev"
}

# VPC Configuration
variable "vpc_cidr" {
    type        = string
    description = "CIDR block for the VPC"
    default     = "10.0.0.0/16"
}

# Subnet Configuration
variable "public_subnet_cidrs" {
    type        = list(string)
    description = "List of CIDR blocks for public subnets"
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
    type        = list(string)
    description = "List of CIDR blocks for private subnets"
    default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_subnet_cidrs" {
    type        = list(string)
    description = "List of CIDR blocks for database subnets"
    default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

# Optional Tags
variable "vpc_tags" {
    type        = map(string)
    description = "Additional tags for VPC"
    default = {
        project       = "roboshop_local"
        Environment = "DEV"
    }
}

variable "igw_tags" {
    type        = map(string)
    description = "Additional tags for Internet Gateway"
    default = {
        Purpose = "Internet Access"
    }
}

variable "eip_tags" {
    type        = map(string)
    description = "Additional tags for Elastic IP"
    default = {
        Usage = "NAT Gateway"
    }
}
