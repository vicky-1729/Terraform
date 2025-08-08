# Project and Environment Variables
variable "project" {
    type        = string
    description = "Project name for resource naming and tagging"
}

variable "environment" {
    type        = string
    description = "Environment name (dev, staging, prod)"
}

# VPC Configuration
variable "vpc_id" {
    type        = string
    description = "VPC ID where the security group will be created"
}

# Security Group Configuration Variables
variable "sg_name" {
    type        = string
    description = "Name for the security group (will be prefixed with project-environment)"
}

variable "sg_desc" {
    type        = string
    description = "Description for the security group"
}

# Optional Tags Variables
variable "sg_tags" {
    type        = map(string)
    description = "Additional tags for the security group"
    default     = {}
}

