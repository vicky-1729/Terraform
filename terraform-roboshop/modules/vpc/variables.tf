# VPC Configuration Variables
variable "cidr_blocks" {
    type        = string
    description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
}

# Subnet CIDR Configuration
variable "public_subnet_cidrs" {
    type        = list(string)
    description = "List of CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
    type        = list(string)
    description = "List of CIDR blocks for private subnets"
}

variable "db_subnet_cidrs" {
    type        = list(string)
    description = "List of CIDR blocks for database subnets"
}

# Project and Environment Variables
variable "project" {
    type        = string
    description = "Project name for resource naming and tagging"
}

variable "environment" {
    type        = string
    description = "Environment name (dev, staging, prod)"
}

# Optional Tags Variables
variable "vpc_tags" {
    type        = map(string)
    description = "Additional tags for VPC"
    default     = {} 
}

variable "igw_tags" {
    type        = map(string)
    description = "Additional tags for Internet Gateway"
    default     = {}
}
variable "ngw_tags" {
    type        = map(string)
    description = "Additional tags for NAT Gateway"
    default     = {}
}

variable "eip_tags" {
    type        = map(string)
    description = "Additional tags for Elastic IP"
    default     = {}
}

# Route Table Tags Variables
variable "public_route_tags" {
    type        = map(string)
    description = "Additional tags for public route table"
    default     = {}
}

variable "private_route_tags" {
    type        = map(string)
    description = "Additional tags for private route table"
    default     = {}
}

variable "db_route_tags" {
    type        = map(string)
    description = "Additional tags for database route table"
    default     = {}
}

# Subnet Tags Variables
variable "public_tags" {
    type        = map(string)
    description = "Additional tags for public subnets"
    default     = {}
}

variable "private_tags" {
    type        = map(string)
    description = "Additional tags for private subnets"
    default     = {}
}

variable "db_tags" {
    type        = map(string)
    description = "Additional tags for database subnets"
    default     = {}
}

