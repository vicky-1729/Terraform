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


variable "zone_id"{
    type        = string
    default     = "xxxxxxxxx"
}
variable "zone_name"{
    type        = string
    default     = "xxxxxxxxx"
}
