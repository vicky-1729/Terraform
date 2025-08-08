variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-09c813fb71547fc4f"
}

variable "env" {
  description = "Environment (dev/prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "roboshop"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instances" {
  description = "List of instance components"
  type        = list(string)
  default     = ["mongodb", "redis"]
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "allow-all"
}

variable "sg_description" {
  description = "Description of the security group"
  type        = string
  default     = "allow - inbound and outbound"
}

variable "from_port" {
  description = "Starting port number for security group rules"
  type        = number
  default     = 0
}

variable "to_port" {
  description = "Ending port number for security group rules"
  type        = number
  default     = 0
}

variable "protocol" {
  description = "Protocol for security group rules"
  type        = string
  default     = "-1"
}

variable "sg_tags" {
  description = "Base tag for security group name"
  type        = string
  default     = "allow"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project   = "roboshop"
    Terraform = "true"
  }
}