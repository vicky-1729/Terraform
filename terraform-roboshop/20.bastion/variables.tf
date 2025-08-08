# Project and Environment Variables
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

# Instance Configuration
variable "instance_type" {
    type        = string
    description = "EC2 instance type for bastion host"
    default     = "t3.micro"
}

