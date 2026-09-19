# Terraform File Structure

## Topics Covered

- Terraform file organization
- How Terraform loads `.tf` files
- Terraform dependency management
- Best practices for file structure
- Code organization patterns
- Environment-specific structure
- Service-based structure
- Common file organization mistakes

---

## 1. Terraform File Loading

Terraform treats all `.tf` files in the **same working directory** as a single configuration.

Example:

```text
terraform-project/
├── backend.tf
├── versions.tf
├── provider.tf
├── variables.tf
├── locals.tf
├── vpc.tf
├── storage.tf
└── outputs.tf

Terraform loads the configuration from all .tf files and evaluates them together.

Important Points

Terraform loads all .tf files in the current directory.

All .tf files are treated as one Terraform configuration.

File names are primarily used for organization and readability.

Terraform does not depend on files being executed sequentially.

Terraform builds a dependency graph based on resource references.

Resources can reference variables, locals, and resources defined in other .tf files.

File names do not determine resource creation order.


Example

vpc.tf:

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

variables.tf:

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

Terraform understands the relationship automatically.

Terraform's Dependency Model

Multiple .tf files
        │
        ▼
Terraform combines configuration
        │
        ▼
Terraform analyzes references
        │
        ▼
Dependency Graph
        │
        ▼
Terraform determines resource order
        │
        ▼
Create / Update / Destroy resources

> Key Point: Terraform does not execute .tf files based on alphabetical order. The dependency graph determines resource relationships.




---

2. Recommended Terraform File Structure

A clean Terraform project can be organized like this:

project-root/
│
├── backend.tf           # Backend configuration
├── versions.tf          # Terraform and provider versions
├── provider.tf          # Provider configuration
│
├── variables.tf         # Input variable definitions
├── locals.tf            # Local value definitions
│
├── main.tf              # Common/main resources
├── vpc.tf               # VPC and networking
├── security.tf          # Security groups, NACLs, IAM
├── compute.tf           # EC2, ASG, Load Balancers
├── storage.tf           # S3, EBS, EFS
├── database.tf          # RDS, DynamoDB
│
├── outputs.tf           # Output definitions
├── terraform.tfvars     # Variable values
│
├── .gitignore
└── README.md            # Documentation


---

3. File Responsibilities

backend.tf

Contains Terraform backend configuration.

terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

The backend determines where Terraform stores its state.


---

versions.tf

Contains Terraform and provider version requirements.

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

Keeping version constraints separate makes the configuration easier to understand and maintain.


---

provider.tf

Contains provider configuration.

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}


---

4. variables.tf

Contains input variable definitions.

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"

  validation {
    condition = contains(
      ["dev", "staging", "production"],
      var.environment
    )

    error_message = "Environment must be dev, staging, or production."
  }
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}


---

5. locals.tf

Locals are useful for reusable values, naming conventions, and common configuration.

locals {
  # Common tags applied to resources
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })

  # Naming convention
  name_prefix = "${var.project_name}-${var.environment}"

  # Network configuration
  vpc_name = "${local.name_prefix}-vpc"

  # Storage configuration
  bucket_name = "${local.name_prefix}-${random_id.bucket_suffix.hex}"
}

# Random suffix for globally unique names
resource "random_id" "bucket_suffix" {
  byte_length = 4

  keepers = {
    project     = var.project_name
    environment = var.environment
  }
}


---

6. vpc.tf

Keep networking resources together.

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = local.vpc_name
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    Type = "Public"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


---

7. storage.tf

Keep storage resources together.

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name

  tags = merge(local.common_tags, {
    Name        = local.bucket_name
    Purpose     = "General storage"
    Environment = var.environment
  })
}

# S3 Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

# S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


---

8. outputs.tf

Outputs expose useful information after Terraform creates infrastructure.

# VPC Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# Subnet Outputs

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

# S3 Outputs

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

# Environment Outputs

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "common_tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}


---

9. terraform.tfvars

terraform.tfvars contains values for input variables.

# Project Configuration

project_name = "aws-terraform-course"
environment  = "staging"
region       = "us-east-1"

# Network Configuration

vpc_cidr           = "10.0.0.0/16"
availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

# Tags

tags = {
  Owner      = "DevOps-Team"
  Department = "Engineering"
  CostCenter = "Engineering-001"
  Project    = "TerraformLearning"
}

Important

The value of environment must match the validation rule.

If the validation is:

contains(["dev", "staging", "production"], var.environment)

Then:

environment = "demo"

is invalid.

Use:

environment = "staging"

or modify the validation rule to include "demo".


---

10. File Organization Principles

10.1 Separation of Concerns

Keep different responsibilities in separate files.

vpc.tf
    ↓
Networking

security.tf
    ↓
Security

compute.tf
    ↓
Compute

storage.tf
    ↓
Storage

database.tf
    ↓
Database


---

10.2 Logical Grouping

Group related resources together.

Example:

vpc.tf
├── VPC
├── Internet Gateway
├── Subnets
├── Route Tables
└── Route Table Associations


---

10.3 Consistent Naming

Use clear and predictable names.

Good

vpc.tf
security.tf
compute.tf
storage.tf
database.tf

Avoid

stuff.tf
new.tf
test2.tf
final.tf
final-final.tf
misc.tf


---

10.4 Keep Files Manageable

Avoid putting thousands of lines into a single file.

Instead of:

main.tf
└── 2,000+ lines

consider:

vpc.tf
security.tf
compute.tf
database.tf
storage.tf

There is no strict Terraform line-count requirement. The goal is maintainability and readability.


---

11. Terraform Modules

Use modules when infrastructure needs to be reused or standardized.

Example:

modules/
├── vpc/
├── security/
├── compute/
└── database/

Example module usage:

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"
}

Use modules when:

Infrastructure is reused.

Multiple environments need the same infrastructure pattern.

Teams need standardized infrastructure.

A component has a clear reusable interface.

The Terraform configuration has grown significantly.



---

12. Environment-Specific Structure

For larger projects, environments can be separated.

terraform/
│
├── environments/
│   │
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   │
│   ├── staging/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   │
│   └── production/
│       ├── backend.tf
│       ├── main.tf
│       └── terraform.tfvars
│
└── modules/
    ├── vpc/
    ├── security/
    └── compute/

This allows each environment to have its own configuration and state.


---

13. Service-Based Structure

For larger infrastructure, resources can also be organized by service or function.

infrastructure/
│
├── networking/
│   ├── vpc.tf
│   ├── subnets.tf
│   └── routing.tf
│
├── security/
│   ├── security-groups.tf
│   ├── nacls.tf
│   └── iam.tf
│
├── compute/
│   ├── ec2.tf
│   ├── autoscaling.tf
│   └── load-balancers.tf
│
├── storage/
│   ├── s3.tf
│   ├── ebs.tf
│   └── efs.tf
│
└── data/
    ├── rds.tf
    ├── dynamodb.tf
    └── elasticache.tf

This pattern is useful when the infrastructure becomes large and multiple teams work on different areas.


---

14. Terraform Dependency Model

Terraform automatically identifies dependencies between resources.

Example:

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

A subnet references the VPC:

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

Terraform creates an implicit dependency:

aws_vpc.main
      │
      ▼
aws_subnet.public

Terraform knows the VPC must exist before the subnet.

Implicit Dependency

Created automatically through resource references:

vpc_id = aws_vpc.main.id

Explicit Dependency

Can be defined using depends_on:

depends_on = [
  aws_vpc.main
]

Use depends_on only when Terraform cannot determine the dependency automatically.


---

15. Terraform Commands

Initialize

terraform init

Downloads providers, initializes the backend, and prepares the working directory.


---

Format

terraform fmt -recursive

Formats Terraform files consistently.


---

Validate

terraform validate

Checks whether the Terraform configuration is syntactically and structurally valid.


---

Plan

terraform plan

Shows the changes Terraform intends to make.


---

Apply

terraform apply

Creates or updates the infrastructure.


---

Destroy

terraform destroy

Destroys resources managed by the Terraform configuration.


---

16. Recommended Terraform Workflow

Write / Modify Terraform Code
            │
            ▼
     terraform fmt
            │
            ▼
     terraform init
            │
            ▼
   terraform validate
            │
            ▼
      terraform plan
            │
            ▼
      Review Changes
            │
            ▼
     terraform apply
            │
            ▼
      Verify Resources

For production environments, always review the Terraform plan before applying changes.


---

17. Common File Organization Mistakes

Mistake 1: Everything in main.tf

main.tf
└── 2,000+ lines

Problem

Difficult to navigate

Difficult to maintain

Difficult for teams to collaborate


Better

vpc.tf
security.tf
compute.tf
storage.tf
database.tf


---

Mistake 2: Inconsistent Naming

Avoid:

network.tf
vpc-final.tf
newnetwork.tf
network2.tf

Prefer:

vpc.tf


---

Mistake 3: Mixing Unrelated Resources

Avoid putting everything randomly into one file:

VPC
RDS
IAM
S3
EC2

Group resources logically.


---

Mistake 4: No Documentation

Include:

README.md

Document:

Infrastructure purpose

Required variables

AWS region

Deployment steps

Backend requirements

Environment information

Important dependencies

Prerequisites



---

Mistake 5: Overengineering

Do not create a complicated structure for a small project.

Small Project

terraform/
├── provider.tf
├── variables.tf
├── locals.tf
├── vpc.tf
├── storage.tf
└── outputs.tf

Large Project

environments/
modules/
networking/
security/
compute/
storage/
data/

Use a structure appropriate to the size and complexity of the infrastructure.


---

18. Interview Questions

Q1. Does Terraform execute .tf files alphabetically?

Answer:

No.

Terraform loads the .tf files in the working directory as a single configuration. It uses the dependency graph to determine relationships and resource ordering.


---

Q2. Does the filename affect Terraform functionality?

Answer:

Generally, no.

File names are mainly used to organize the Terraform configuration and make it easier for humans to understand and maintain.


---

Q3. Can a resource in vpc.tf reference a variable from variables.tf?

Answer:

Yes.

# vpc.tf

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

The location of the variable definition in another .tf file does not prevent Terraform from using it.


---

Q4. Why split Terraform into multiple files?

Answer:

To improve:

Readability

Maintainability

Team collaboration

Troubleshooting

Navigation

Separation of concerns



---

Q5. When should Terraform modules be used?

Answer:

Modules should be used when infrastructure components need to be reused, standardized, or maintained independently.


---

Q6. What determines Terraform resource creation order?

Answer:

Terraform uses its dependency graph.

Dependencies can be:

Implicit

vpc_id = aws_vpc.main.id

Explicit

depends_on = [
  aws_vpc.main
]


---

19. Final Recommended Structure

For a practical AWS DevOps Terraform project:

terraform-project/
│
├── backend.tf
├── versions.tf
├── provider.tf
│
├── variables.tf
├── locals.tf
│
├── main.tf
├── vpc.tf
├── security.tf
├── compute.tf
├── storage.tf
├── database.tf
│
├── outputs.tf
├── terraform.tfvars
│
├── .gitignore
└── README.md

Core Concept

.tf Files
            │
            ▼
   Single Configuration
            │
            ▼
    Dependency Analysis
            │
            ▼
     Dependency Graph
            │
            ▼
 Terraform Determines Order
            │
            ▼
   Create / Update / Destroy

> Remember: File structure is primarily for humans. Terraform uses the dependency graph to understand relationships and determine resource ordering.