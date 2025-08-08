# AWS Security Group Terraform Module

## 📋 Overview
This Terraform module creates a reusable AWS Security Group with outbound traffic allowed by default. It's designed to be flexible and can be used for different types of applications (frontend, backend, database, etc.) with custom naming and tagging.

## 🔧 Features

### ✅ **Flexible Security Group Creation**
- Dynamic naming based on project, environment, and security group name
- Customizable description for clear identification
- VPC association through local values

### ✅ **Default Outbound Rules**
- All outbound traffic allowed (0.0.0.0/0)
- Supports internet connectivity for updates and external API calls
- Ready for additional inbound rules to be added externally

### ✅ **Consistent Tagging**
- Merges common tags with custom tags
- Project and environment-based naming convention
- Optional additional tags for cost allocation and management

## 📦 Resources Created

| Resource | Count | Purpose |
|----------|--------|---------|
| `aws_security_group` | 1 | Main security group with VPC association |
| `aws_security_group_rule` | 1 | Egress rule allowing all outbound traffic |

## 📋 Requirements

### **Terraform Version**
- Terraform >= 1.0
- AWS Provider >= 4.0

### **Dependencies**
- VPC must exist (referenced through `local.vpc_id`)
- Common tags should be defined in `local.common_tags`

### **AWS Permissions**
- EC2 security group management permissions
- VPC read permissions

## 🔧 Usage

### **Basic Example**
```hcl
module "frontend_sg" {
  source = "../modules/sg"
  
  # Required Variables
  project     = "roboshop"
  environment = "dev"
  sg_name     = "frontend"
  sg_desc     = "Security group for frontend web servers"
}
```

### **Advanced Example with Custom Tags**
```hcl
module "backend_sg" {
  source = "../modules/sg"
  
  # Required Variables
  project     = "roboshop"
  environment = "prod"
  sg_name     = "backend-api"
  sg_desc     = "Security group for backend API servers"
  
  # Optional Custom Tags
  sg_tags = {
    Team        = "Backend Team"
    CostCenter  = "Infrastructure"
    Backup      = "Required"
    Monitoring  = "Enabled"
  }
}
```

### **Multiple Security Groups**
```hcl
# Frontend Security Group
module "frontend_sg" {
  source = "../modules/sg"
  
  project     = "roboshop"
  environment = "dev"
  sg_name     = "frontend"
  sg_desc     = "Security group for frontend load balancers and web servers"
}

# Backend Security Group
module "backend_sg" {
  source = "../modules/sg"
  
  project     = "roboshop"
  environment = "dev"
  sg_name     = "backend"
  sg_desc     = "Security group for backend application servers"
}

# Database Security Group
module "database_sg" {
  source = "../modules/sg"
  
  project     = "roboshop"
  environment = "dev"
  sg_name     = "database"
  sg_desc     = "Security group for RDS and database servers"
}
```

## 📝 Variables

### **Required Variables**

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `project` | `string` | Project name for resource naming | `"roboshop"` |
| `environment` | `string` | Environment name | `"dev"`, `"staging"`, `"prod"` |
| `sg_name` | `string` | Security group identifier | `"frontend"`, `"backend"`, `"database"` |
| `sg_desc` | `string` | Security group description | `"Security group for frontend servers"` |

### **Optional Variables**

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `sg_tags` | `map(string)` | `{}` | Additional tags for the security group |

## 📊 Outputs

| Output | Description | Example Value |
|--------|-------------|---------------|
| `sg_id` | Security Group ID | `sg-12345678901234567` |
| `sg_name` | Security Group Name | `roboshop-dev-frontend` |
| `sg_arn` | Security Group ARN | `arn:aws:ec2:us-east-1:123456789012:security-group/sg-12345678` |

## 🏷️ Resource Naming Convention

All resources follow a consistent naming pattern:
```
{project}-{environment}-{sg_name}
```

### **Examples:**
- **Frontend**: `roboshop-dev-frontend`
- **Backend**: `roboshop-prod-backend-api`
- **Database**: `roboshop-staging-database`
- **Load Balancer**: `roboshop-dev-alb-public`

## 🔒 Security Configuration

### **Default Egress Rules**
```
Type: Egress (Outbound)
Protocol: All (-1)
Port Range: All (0-65535)
Destination: 0.0.0.0/0 (Anywhere)
Description: Allow all outbound traffic
```

### **Ingress Rules**
- **No default ingress rules** - must be added separately
- Use `aws_security_group_rule` resources to add specific inbound rules
- Follow principle of least privilege

## 🔗 Adding Ingress Rules

After creating the security group, add specific ingress rules:

```hcl
# Allow HTTP traffic from ALB
resource "aws_security_group_rule" "frontend_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.alb_sg.sg_id
  security_group_id        = module.frontend_sg.sg_id
  description              = "Allow HTTP from ALB"
}

# Allow SSH from bastion
resource "aws_security_group_rule" "frontend_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.frontend_sg.sg_id
  description              = "Allow SSH from bastion host"
}
```

## 📚 Best Practices

### ✅ **Security**
- Only allow necessary inbound traffic
- Use security group references instead of CIDR blocks when possible
- Add descriptive names and descriptions
- Regular security reviews

### ✅ **Naming**
- Use consistent naming conventions
- Include environment in names
- Use descriptive sg_name values
- Avoid special characters

### ✅ **Tagging**
- Include project and environment tags
- Add cost allocation tags
- Use team/owner identification tags
- Follow organizational tagging standards

## 🛠️ Integration with Other Modules

### **VPC Module Integration**
```hcl
# In locals.tf or data.tf
locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.environment}/vpc_id"
}
```

### **Application Module Usage**
```hcl
module "frontend_sg" {
  source = "../modules/sg"
  # ... configuration ...
}

module "frontend_servers" {
  source = "../modules/ec2"
  
  security_group_ids = [module.frontend_sg.sg_id]
  # ... other configuration ...
}
```

## ⚠️ Important Notes

- **Outbound Traffic**: All outbound traffic is allowed by default
- **Inbound Rules**: Must be added separately using `aws_security_group_rule`
- **VPC Dependency**: Requires VPC to exist and be accessible through locals
- **State Management**: Security group changes may require resource replacement

## 🔧 Troubleshooting

### **Common Issues:**

| Issue | Solution |
|-------|----------|
| "VPC not found" | Ensure `local.vpc_id` is properly configured |
| "Invalid security group name" | Check naming conventions and length limits |
| "Tags limit exceeded" | Reduce number of custom tags |
| "Circular dependency" | Review security group rule references |

## 📞 Support

For issues or questions:
- Review AWS Security Group documentation
- Check VPC and networking configuration
- Validate IAM permissions
- Ensure proper module dependencies

---

**Module Version**: 1.0  
**Last Updated**: June 2025  
**Terraform Version**: >= 1.0  
**AWS Provider**: >= 4.0
