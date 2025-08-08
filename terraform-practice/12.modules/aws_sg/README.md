# AWS Security Group Terraform Module

This module creates an AWS Security Group with configurable ingress and egress rules.

## Features

- Creates a single AWS Security Group in the specified VPC
- Configurable name, description, and tags
- Consistent naming convention with project and environment prefixes
- Exports security group ID as module output

## Usage

```terraform
module "app_sg" {
  source      = "git::https://github.com/vicky-1729/Devops.git//Terraform/practice/12.modules/aws_sg?ref=main"
  
  sg_name     = "app-sg"
  sg_desc     = "Security group for application servers"
  vpc_id      = "vpc-1234567890abcdef0"
  environment = "dev"
  project     = "roboshop"
  
  sg_tags     = {
    ManagedBy = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| sg_name | Name of the security group | `string` | n/a | yes |
| sg_desc | Description of the security group | `string` | n/a | yes |
| vpc_id | ID of the VPC where the security group will be created | `string` | n/a | yes |
| environment | Deployment environment (e.g., dev, stage, prod) | `string` | n/a | yes |
| project | Project name for resource organization | `string` | n/a | yes |
| sg_tags | Additional tags to attach to the security group | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| sg_id | ID of the created security group |

## Example with Custom Rules

```terraform
module "web_sg" {
  source      = "git::https://github.com/vicky-1729/Devops.git//Terraform/practice/12.modules/aws_sg?ref=main"
  
  sg_name     = "web-sg"
  sg_desc     = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id
  environment = "prod"
  project     = "roboshop"
}

resource "aws_security_group_rule" "http" {
  security_group_id = module.web_sg.sg_id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https" {
  security_group_id = module.web_sg.sg_id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
```

## License

MIT
