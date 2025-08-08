# Project and Environment Variables
variable "project" {
    type        = string
    description = "Project name for resource naming and tagging"
    default = "roboshop"
}

variable "environment" {
    type        = string
    description = "Environment name (dev, staging, prod)"
    default = "dev"
}

# Security Group Configuration Variables
variable "frontend_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "frontend_sg"
}

variable "frontend_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "frontend security group"
}
# Security Group Configuration Variables
variable "bastion_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "bastion_sg"
}

variable "bastion_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "bastion security group"
}
# Security Group Configuration Variables
variable "backend_alb_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "backend_alb_sg"
}

variable "backend_alb_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "backend security group"
}
# Security Group Configuration Variables
variable "vpn_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "vpn_security_group"
}

variable "vpn_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "vpn security group"
}

# Security Group Configuration Variables mysql
variable "mysql_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "mysql_sg"
}

variable "mysql_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "mysql security group"
}

# Security Group Configuration Variables rabbitmq
variable "rabbitmq_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "rabbitmq_sg"
}

variable "rabbitmq_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "rabbitmq security group"
}

# Security Group Configuration Variables redis
variable "redis_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "redis_sg"
}

variable "redis_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "redis security group"
}


# Security Group Configuration Variables mongodb
variable "mongodb_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "mongodb_sg_name"
}

variable "mongodb_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "mongodb security group"
}
# Security Group Configuration Variables mongodb
variable "catalogue_sg_name" {
    type        = string
    description = "Name for the security group"
    default = "catalogue_sg_name"
}

variable "catalogue_sg_desc" {
    type        = string
    description = "Description for the security group"
    default = "catalogue security group"
}

# MongoDB inbound ports configuration
# Default ports: 22 (SSH), 27017 (MongoDB default port)
variable "mongodb_inbound_ports"{
    type        = list(string)
    description = "List of ports to allow inbound access to MongoDB servers"
    default     = ["22", "27017"]
}

variable "mysql_inbound_ports"{
    type        = list(string)
    description = "List of ports to allow inbound access to mysql servers"
    default     = ["22", "3306"]
}

variable "rabbitmq_inbound_ports"{
    type        = list(string)
    description = "List of ports to allow inbound access to rabbit servers"
    default     = ["22", "5672"]
}
variable "redis_inbound_ports"{
    type        = list(string)
    description = "List of ports to allow inbound access to redis servers"
    default     = ["22", "6379"]
}
variable "catalogue_inbound_ports"{
    type        = list(string)
    description = "List of ports to allow inbound access to redis servers"
    default     = ["22", "8080"]
}