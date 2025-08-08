# AWS VPC Terraform Module

## 📋 Overview
This Terraform module creates a complete AWS VPC infrastructure with a **3-tier architecture** suitable for production workloads. It provides public, private, and database subnets across multiple availability zones.

## 🏗️ Architecture

```
Internet Gateway
       │
   ┌───▼───┐
   │  VPC  │
   └───┬───┘
       │
   ┌───▼────────────────────┐
   │   Public Subnets       │ ← Web Servers, Load Balancers
   │  (Auto Public IP)      │
   └────────────────────────┘
   ┌────────────────────────┐
   │   Private Subnets      │ ← Application Servers
   │  (NAT Gateway Access)  │
   └────────────────────────┘
   ┌────────────────────────┐
   │   Database Subnets     │ ← RDS, Databases
   │     (Isolated)         │
   └────────────────────────┘
```

## 🚀 Features

### ✅ **Complete VPC Setup**
- VPC with DNS hostnames enabled
- Internet Gateway for public access
- Elastic IP for NAT Gateway (ready for NAT setup)

### ✅ **Multi-Tier Subnets**
- **Public Subnets**: Auto-assign public IPs, internet accessible
- **Private Subnets**: No public IPs, for application servers
- **Database Subnets**: Isolated tier for databases

### ✅ **High Availability**
- Subnets distributed across multiple availability zones
- Configurable number of AZs (default: 2)
- Dynamic AZ selection from available zones

### ✅ **Flexible Configuration**
- Customizable CIDR blocks for all subnet types
- Optional tags for all resources
- Environment and project-based naming

## 📦 Resources Created

| Resource | Count | Purpose |
|----------|--------|---------|
| `aws_vpc` | 1 | Main VPC with DNS enabled |
| `aws_internet_gateway` | 1 | Internet access for public subnets |
| `aws_subnet` (public) | Variable | Public tier subnets |
| `aws_subnet` (private) | Variable | Application tier subnets |
| `aws_subnet` (database) | Variable | Database tier subnets |
| `aws_eip` | 1 | Elastic IP for NAT Gateway |

## 📋 Requirements

### **Terraform Version**
- Terraform >= 1.0
- AWS Provider >= 4.0

### **AWS Permissions**
- EC2 VPC management permissions
- Ability to create/modify VPC resources

## 🔧 Usage

### **Basic Example**
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  # Required Variables
  project              = "roboshop"
  environment          = "dev"
  cidr_blocks          = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  db_subnet_cidrs      = ["10.0.21.0/24", "10.0.22.0/24"]
}
```

### **Advanced Example with Custom Tags**
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  # Required Variables
  project              = "roboshop"
  environment          = "prod"
  cidr_blocks          = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  db_subnet_cidrs      = ["10.0.21.0/24", "10.0.22.0/24"]
  
  # Optional Tags
  vpc_tags = {
    Owner = "DevOps Team"
    Cost  = "Infrastructure"
  }
  
  igw_tags = {
    Purpose = "Internet Access"
  }
  
  eip_tags = {
    Usage = "NAT Gateway"
  }
}
```

## 📝 Variables

### **Required Variables**

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `cidr_blocks` | `string` | CIDR block for VPC | `"10.0.0.0/16"` |
| `public_subnet_cidrs` | `list(string)` | CIDR blocks for public subnets | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | `list(string)` | CIDR blocks for private subnets | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `db_subnet_cidrs` | `list(string)` | CIDR blocks for database subnets | `["10.0.21.0/24", "10.0.22.0/24"]` |
| `project` | `string` | Project name for resource naming | `"roboshop"` |
| `environment` | `string` | Environment name | `"dev"` |

### **Optional Variables**

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vpc_tags` | `map(string)` | `{}` | Additional tags for VPC |
| `igw_tags` | `map(string)` | `{}` | Additional tags for Internet Gateway |
| `eip_tags` | `map(string)` | `{}` | Additional tags for Elastic IP |

## 📊 Outputs

| Output | Description | Example Value |
|--------|-------------|---------------|
| `vpc_id` | VPC ID | `vpc-12345678` |
| `vpc_cidr_block` | VPC CIDR block | `10.0.0.0/16` |
| `public_subnet_ids` | List of public subnet IDs | `["subnet-123", "subnet-456"]` |
| `private_subnet_ids` | List of private subnet IDs | `["subnet-789", "subnet-abc"]` |
| `database_subnet_ids` | List of database subnet IDs | `["subnet-def", "subnet-ghi"]` |
| `internet_gateway_id` | Internet Gateway ID | `igw-12345678` |
| `nat_eip_id` | NAT Elastic IP ID | `eipalloc-12345678` |

## 🏷️ Resource Naming Convention

All resources follow a consistent naming pattern:
```
{project}-{environment}-{resource-type}-{availability-zone}
```

### **Examples:**
- **VPC**: `roboshop-dev-vpc`
- **IGW**: `roboshop-dev-igw`
- **Public Subnet**: `roboshop-dev-public-us-east-1a`
- **Private Subnet**: `roboshop-dev-private-us-east-1b`
- **Database Subnet**: `roboshop-dev-database-us-east-1a`
- **NAT EIP**: `roboshop-dev-nat-eip`

## 🛠️ Next Steps

After creating the VPC, you typically need to add:

1. **NAT Gateway** for private subnet internet access
2. **Route Tables** and routes for proper traffic flow
3. **Security Groups** for application-specific access
4. **Network ACLs** for additional security (optional)

## 📚 Best Practices

### ✅ **CIDR Planning**
- Use non-overlapping CIDR blocks
- Reserve space for future subnets
- Follow RFC 1918 private address space

### ✅ **Availability Zones**
- Use at least 2 AZs for high availability
- Distribute subnets evenly across AZs
- Consider AZ capacity and pricing

### ✅ **Tagging Strategy**
- Include project, environment, and owner tags
- Use consistent tag naming conventions
- Add cost allocation tags for billing

## ⚠️ Important Notes

- **Subnet Count**: Number of subnets must not exceed available AZs
- **CIDR Overlap**: Ensure subnet CIDRs don't overlap
- **AZ Limit**: Module currently supports up to 2 AZs (configurable in locals)
- **Dependencies**: VPC must be created before dependent resources

## 🔧 Troubleshooting

### **Common Issues:**

| Issue | Solution |
|-------|----------|
| "No available AZs" | Check region has enough AZs |
| "CIDR overlap" | Verify subnet CIDRs don't overlap |
| "Invalid CIDR" | Ensure proper CIDR format |
| "Too many subnets" | Reduce subnet count or increase AZ limit |

## 📞 Support

For issues or questions:
- Check AWS VPC documentation
- Validate CIDR block planning
- Ensure proper IAM permissions
- Review Terraform plan before apply

---

**Module Version**: 1.0  
**Last Updated**: June 2025  
**Terraform Version**: >= 1.0  
**AWS Provider**: >= 4.0
