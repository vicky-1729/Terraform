# Terraform File Structure and Organization

This guide explains how Terraform loads configuration files, how to organize a project, and when to use modules or separate environments.

## 1. How Terraform Loads Files

Terraform treats every `.tf` file in the same working directory as one configuration. File names are used for organization and readability; they do not define execution order.

For example, Terraform combines these files before evaluating the configuration:

```text
terraform-project/
├── backend.tf
├── versions.tf
├── provider.tf
├── variables.tf
├── locals.tf
├── vpc.tf
├── compute.tf
├── storage.tf
└── outputs.tf
```

Terraform analyzes references between resources and builds a dependency graph. That graph determines which resources must be created, updated, or destroyed first.

```text
Terraform loads all .tf files
            │
            ▼
     Terraform builds a
     dependency graph
            │
            ▼
 Terraform determines the order
 of resource operations
```

For example, this reference creates an implicit dependency:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

Terraform knows that the VPC must exist before the subnet because the subnet references `aws_vpc.main.id`.

## 2. Recommended Project Structure

A small or medium-sized Terraform project can use the following structure:

```text
terraform-project/
├── backend.tf           # Remote state configuration
├── versions.tf          # Terraform and provider requirements
├── provider.tf          # Provider configuration
├── variables.tf         # Input variable declarations
├── locals.tf            # Reusable local values
├── main.tf              # Shared or primary resources
├── vpc.tf               # Networking resources
├── security.tf          # Security groups, NACLs, and IAM
├── compute.tf           # EC2, load balancers, and autoscaling
├── storage.tf           # S3, EBS, and EFS
├── database.tf          # RDS, DynamoDB, and other databases
├── outputs.tf           # Output values
├── terraform.tfvars     # Environment-specific variable values
├── .gitignore
└── README.md
```

The exact file names are flexible. The important principle is to group related resources and keep each file easy to navigate.

## 3. File Responsibilities

### `backend.tf`

Defines where Terraform stores its state.

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

The backend configuration is usually environment-specific. Do not commit credentials or other secrets to this file.

### `versions.tf`

Defines the Terraform and provider versions required by the project.

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
```

Version constraints make deployments more predictable across developers and CI/CD systems.

### `provider.tf`

Configures the providers used by the project.

```hcl
provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}
```

### `variables.tf`

Declares input variables and, when appropriate, validates their values.

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability zones for public subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
```

### `locals.tf`

Defines reusable values such as naming conventions and common tags.

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })

  vpc_name = "${local.name_prefix}-vpc"
}
```

Locals improve consistency and reduce repeated expressions. Avoid putting values in `locals.tf` that should be supplied by users as variables.

### Resource files

Resource files should group related infrastructure. For example, `vpc.tf` can contain the VPC, subnets, route tables, and internet gateway.

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = local.vpc_name
  })
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${count.index + 1}"
    Type = "Public"
  })
}
```

### `outputs.tf`

Exposes values that are useful to users, other configurations, or automation.

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}
```

### `terraform.tfvars`

Stores values for input variables. Keep secrets out of source control; use environment variables, a secrets manager, or a protected CI/CD variable store instead.

```hcl
project_name       = "aws-terraform-course"
environment        = "staging"
region             = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

tags = {
  Owner      = "DevOps-Team"
  Department = "Engineering"
  CostCenter = "Engineering-001"
}
```

Variable values must satisfy the validation rules declared in `variables.tf`. For example, `environment = "demo"` is invalid when only `dev`, `staging`, and `production` are allowed.

## 4. Organization Principles

### Separate responsibilities

Keep networking, security, compute, storage, and databases in logical groups. This makes changes easier to review and troubleshoot.

### Use consistent names

Prefer descriptive names such as:

```text
vpc.tf
security.tf
compute.tf
storage.tf
database.tf
```

Avoid names that do not communicate purpose, such as `stuff.tf`, `new.tf`, `test2.tf`, or `final-final.tf`.

### Keep files manageable

There is no strict line-count limit for Terraform files. Split a large file when doing so improves navigation, ownership, or reviewability. Do not create extra files merely to follow a rigid template.

### Avoid unnecessary dependencies

Terraform can infer most dependencies from resource references. Use `depends_on` only when a dependency cannot be represented through an expression.

```hcl
resource "aws_instance" "example" {
  depends_on = [aws_iam_role_policy.example]
}
```

## 5. Modules

Use a module when infrastructure needs to be reused, standardized, or maintained behind a clear interface.

```text
terraform-project/
├── main.tf
└── modules/
    ├── vpc/
    ├── security/
    ├── compute/
    └── database/
```

Example module usage:

```hcl
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}
```

Good reasons to create a module include:

- The same infrastructure is used by multiple environments.
- A team needs a standardized implementation.
- A component has a stable and reusable interface.
- The root configuration has become difficult to maintain.

Do not create a module solely to avoid having a few resources in the root configuration. A module should reduce duplication or establish a meaningful boundary.

## 6. Environment-Specific Structure

For larger projects, separate environment configuration from reusable modules:

```text
terraform/
├── environments/
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── production/
│       ├── backend.tf
│       ├── main.tf
│       └── terraform.tfvars
└── modules/
    ├── vpc/
    ├── security/
    └── compute/
```

This approach gives each environment its own variables and state while allowing all environments to share the same modules.

Another option is to keep one root configuration and use workspaces. Workspaces can be useful for similar deployments, but separate directories are often clearer when environments require different backends, permissions, or infrastructure.

## 7. Service-Based Structure

Very large configurations may be organized by service or platform capability:

```text
infrastructure/
├── networking/
│   ├── vpc.tf
│   ├── subnets.tf
│   └── routing.tf
├── security/
│   ├── security-groups.tf
│   ├── nacls.tf
│   └── iam.tf
├── compute/
│   ├── ec2.tf
│   ├── autoscaling.tf
│   └── load-balancers.tf
├── storage/
│   ├── s3.tf
│   ├── ebs.tf
│   └── efs.tf
└── data/
    ├── rds.tf
    ├── dynamodb.tf
    └── elasticache.tf
```

Use this structure when the infrastructure is large enough to benefit from clear ownership boundaries. For smaller projects, it may add unnecessary complexity.

## 8. Terraform Workflow

Run the following commands from the directory containing the root configuration:

```bash
# Format the configuration
terraform fmt -recursive

# Initialize providers and the backend
terraform init

# Validate syntax and configuration structure
terraform validate

# Preview proposed changes
terraform plan

# Apply reviewed changes
terraform apply

# Remove managed infrastructure when it is no longer required
terraform destroy
```

A typical workflow is:

```text
Write or modify configuration
            ↓
       terraform fmt
            ↓
       terraform init
            ↓
     terraform validate
            ↓
       terraform plan
            ↓
      Review the plan
            ↓
       terraform apply
```

Always review the plan carefully, especially for production environments.

## 9. Common Mistakes

### Putting everything in `main.tf`

Thousands of lines in one file make navigation, review, and collaboration difficult. Split resources by responsibility when the configuration grows.

### Using inconsistent file names

Names such as `network.tf`, `vpc-final.tf`, and `network2.tf` make the project harder to understand. Choose one clear name, such as `vpc.tf`, and keep it stable.

### Mixing unrelated resources

Avoid placing VPCs, databases, IAM policies, and S3 buckets together without a clear reason. Logical grouping makes changes easier to find.

### Omitting documentation

A project README should describe its purpose, prerequisites, required variables, AWS region, backend requirements, deployment steps, and environment layout.

### Overengineering a small project

Start with a simple structure. Add modules, separate environments, or service-based directories when the project has a real need for them.

## 10. Interview Questions

### Does Terraform execute `.tf` files alphabetically?

No. Terraform loads all `.tf` files in the working directory as one configuration and uses the dependency graph to determine resource relationships and operation order.

### Does the file name affect Terraform behavior?

Generally, no. File names are mainly for human organization. Terraform does not use them to determine resource creation order.

### Can a resource in one file reference a variable in another file?

Yes. All `.tf` files in the same directory are evaluated as one configuration, so a resource in `vpc.tf` can reference a variable declared in `variables.tf`.

### What determines resource creation order?

Terraform uses its dependency graph. Most dependencies are implicit through references such as `vpc_id = aws_vpc.main.id`. Use `depends_on` only for relationships Terraform cannot infer automatically.

### When should modules be used?

Use modules when infrastructure must be reused, standardized, or maintained behind a clear interface. Avoid modules that only add indirection without reducing duplication or complexity.

### Why split Terraform into multiple files?

Splitting files improves readability, maintainability, code review, troubleshooting, navigation, and team collaboration. It does not change how Terraform evaluates the configuration.

## 11. Key Takeaways

- Terraform treats all `.tf` files in one directory as a single configuration.
- File names organize code for people; the dependency graph controls resource ordering.
- Group related resources by responsibility.
- Use variables for inputs, locals for reusable expressions, and outputs for useful results.
- Use modules for reuse and standardization, not simply because a project has multiple resources.
- Keep environment-specific state and configuration clearly separated when the project grows.
- Run `terraform fmt`, `terraform validate`, and `terraform plan` before applying changes.
