variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "sg_desc" {
  description = "Description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the security group will be created"
  type        = string
}

variable "sg_tags" {
  description = "Additional tags to attach to the security group"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment (e.g., dev, stage, prod)"
  type        = string
}

variable "project" {
  description = "Project name for resource organization"
  type        = string
}