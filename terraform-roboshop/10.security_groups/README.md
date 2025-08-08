# 🛡️ Security Groups Module - Access Control Layer

## 📋 Overview

This module creates and manages all security groups for the RoboShop infrastructure, implementing proper network segmentation and access controls following security best practices.

## 🔒 Security Groups Created

### **Application Tier Security Groups:**
| Security Group | Purpose | Inbound Rules |
|----------------|---------|---------------|
| **frontend_sg** | Web servers | HTTP (80), HTTPS (443), SSH (22) |
| **backend_alb_sg** | Load balancer | HTTP (80) from frontend |
| **catalogue_sg** | Catalog service | Service ports from ALB |

### **Infrastructure Security Groups:**
| Security Group | Purpose | Inbound Rules |
|----------------|---------|---------------|
| **bastion_sg** | SSH jump server | SSH (22) from Internet |
| **vpn_sg** | VPN access | VPN protocols (443, 943, 953, 1194, 22) |

### **Database Security Groups:**
| Security Group | Purpose | Inbound Rules |
|----------------|---------|---------------|
| **mongodb_sg** | MongoDB database | SSH (22) + MongoDB (27017) from Bastion/VPN |
| **redis_sg** | Redis cache | SSH (22) + Redis (6379) from Bastion/VPN |
| **mysql_sg** | MySQL database | SSH (22) + MySQL (3306) from Bastion/VPN |
| **rabbitmq_sg** | Message queue | SSH (22) + RabbitMQ (5672) from Bastion/VPN |

## 🔗 Access Control Matrix

```
Internet
   ↓ (SSH, VPN protocols)
[Bastion SG] + [VPN SG]
   ↓ (HTTP, SSH, DB ports)
[Frontend SG] → [Backend ALB SG] → [Catalogue SG]
   ↓ (Database connections)
[MongoDB SG] + [Redis SG] + [MySQL SG] + [RabbitMQ SG]
```

## 📊 Port Configuration

### **Internet Accessible Ports:**
- **Bastion**: 22 (SSH)
- **VPN**: 22 (SSH), 443 (HTTPS), 943 (Admin), 953 (Client), 1194 (VPN)

### **Database Ports (Internal Only):**
- **MongoDB**: 27017
- **Redis**: 6379  
- **MySQL**: 3306
- **RabbitMQ**: 5672

### **All Services Allow:**
- **SSH (22)**: From Bastion and VPN for management
- **Outbound**: All traffic (0.0.0.0/0) for software updates

## 🚀 Deployment

```bash
cd 10.security_groups/
terraform init
terraform plan    # Review security group rules
terraform apply   # Create all security groups
```

This security layer provides enterprise-grade network security for the RoboShop e-commerce platform! 🚀

## Prerequisites

1. VPC must be deployed first (VPC ID is retrieved from SSM parameter)
2. AWS credentials configured
3. Terraform installed

## Files

- `main.tf` - Main security group module calls and rules
- `variables.tf` - Input variable definitions
- `data.tf` - Data sources for VPC ID from SSM
- `locals.tf` - Local values for VPC ID
- `outputs.tf` - Security group ID outputs
- `ssm_parameter.tf` - Stores SG IDs in SSM for other modules
- `provider.tf` - Provider and Terraform configuration

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Update `terraform.tfvars` with your values if needed

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Rules

- **Frontend**: SSH access from anywhere (port 22)
- **Bastion**: SSH access from anywhere (port 22)
- **Backend ALB**: HTTP access from frontend SG (port 80)

## Dependencies

This configuration depends on:
- VPC resources (via SSM parameter: `/${project}/${environment}/vpc_id`)

## Outputs

- `frontend_sg_id` - Frontend security group ID
- `bastion_sg_id` - Bastion security group ID
- `backend_alb_sg_id` - Backend ALB security group ID

## SSM Parameters Created

- `/${project}/${environment}/frontend_sg_id`
- `/${project}/${environment}/bastion_sg_id`
- `/${project}/${environment}/backend_alb_sg_id`

These parameters are used by other infrastructure modules that need to reference these security groups.
