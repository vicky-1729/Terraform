# AWS VPC Terraform Module

A Terraform module to create an AWS Virtual Private Cloud (VPC) with customizable public, private, and database subnets across multiple availability zones. Supports VPC peering with the default VPC for cross-VPC communication.

## Features

- Creates a fully-functional VPC with customizable CIDR block
- Provisions public, private, and database subnets across two availability zones
- Sets up Internet Gateway for public internet access
- Configures NAT Gateway for private subnet outbound internet access
- Creates appropriate route tables and routes for each subnet tier
- Applies consistent tagging across all resources
- **Supports VPC Peering** with the default VPC (optional)

## Usage

```hcl
module "vpc" {
  source = "./path/to/aws_vpc"

  # Required variables
  project              = "roboshop"
  env                  = "dev"
  cidr_block           = "10.0.0.0/16"
  public_subnet_cidr   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr  = ["10.0.11.0/24", "10.0.12.0/24"]
  db_subnet_cidr       = ["10.0.21.0/24", "10.0.22.0/24"]

  # Optional: add custom tags
  public_tags = {
    Tier = "Public"
  }
  
  private_tags = {
    Tier = "Private"
  }
  
  db_tags = {
    Tier = "Database"
  }

  # Optional: enable VPC peering with default VPC
  is_peering_requried = true
  vpc_peering_tags = {
    Purpose = "Peering with default VPC"
  }
}
```

## VPC Peering

This module can optionally create a VPC peering connection between your custom VPC and the AWS default VPC. When enabled, it:
- Creates a peering connection
- Adds routes in all relevant route tables for cross-VPC communication
- Enables DNS resolution across VPCs

**To enable peering:**
- Set `is_peering_requried = true` in your module block
- Optionally, provide `vpc_peering_tags` for tagging the peering connection

**Use case:**
- Allow resources in your custom VPC to communicate with resources in the default VPC (and vice versa)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cidr_block | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| project | Project name to use in resource naming | `string` | n/a | yes |
| env | Environment name (dev, prod, etc.) | `string` | n/a | yes |
| public_subnet_cidr | List of CIDR blocks for public subnets | `list(string)` | n/a | yes |
| private_subnet_cidr | List of CIDR blocks for private subnets | `list(string)` | n/a | yes |
| db_subnet_cidr | List of CIDR blocks for database subnets | `list(string)` | n/a | yes |
| igw_tags | Additional tags for Internet Gateway | `map(string)` | `{}` | no |
| public_tags | Additional tags for public subnets | `map(string)` | `{}` | no |
| private_tags | Additional tags for private subnets | `map(string)` | `{}` | no |
| db_tags | Additional tags for database subnets | `map(string)` | `{}` | no |
| eip_tags | Additional tags for Elastic IP | `map(string)` | `{}` | no |
| natgateway_tags | Additional tags for NAT Gateway | `map(string)` | `{}` | no |
| public_route_tags | Additional tags for public route table | `map(string)` | `{}` | no |
| private_route_tags | Additional tags for private route table | `map(string)` | `{}` | no |
| db_route_tags | Additional tags for database route table | `map(string)` | `{}` | no |
| is_peering_requried | Enable VPC peering with default VPC | `bool` | `false` | no |
| vpc_peering_tags | Additional tags for VPC peering connection | `map(string)` | `{}` | no |

## Architecture

This module creates the following resources:

1. **VPC** with DNS hostnames enabled
2. **Internet Gateway** attached to the VPC
3. **Public Subnets** in two availability zones with auto-assigned public IPs
4. **Private Subnets** in two availability zones
5. **Database Subnets** in two availability zones
6. **Elastic IP** for NAT Gateway
7. **NAT Gateway** in the first public subnet
8. **Route Tables** for public, private, and database subnets
9. **Routes** for internet access:
   - Public subnets via Internet Gateway
   - Private and database subnets via NAT Gateway
10. **(Optional) VPC Peering** with default VPC and all required routes

## Resource Naming Convention

All resources follow the naming convention: `{project}-{env}-{resource_type}-{additional_info}`

Examples:
- VPC: `roboshop-dev`
- Public Subnet: `roboshop-dev-public-us-east-1a`
- NAT Gateway: `roboshop-dev-NGW`

## Common Tags

All resources are tagged with:
- `project`: The project name
- `env`: The environment name 
- `Terraform`: Set to "true"

## Notes

- This module uses the first two availability zones in the region by default
- NAT Gateway is placed in the first public subnet
- DNS hostnames are enabled on the VPC
