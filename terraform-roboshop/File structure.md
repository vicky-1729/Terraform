

Terraform File Structure

Topics Covered

- Terraform file organization
- How Terraform loads ".tf" files
- Best practices for file structure
- Code organization patterns
- Environment-specific organization
- Service-based organization
- Common file organization mistakes

---

1. Terraform File Loading

Terraform treats all ".tf" files in the same working directory as a single configuration.

For example:

terraform-project/
├── provider.tf
├── variables.tf
├── locals.tf
├── vpc.tf
├── storage.tf
└── outputs.tf

Terraform reads the configuration from all these files together.

Important Points

- Terraform loads all ".tf" files in the current directory.
- The files are combined into a single Terraform configuration.
- File names are primarily for organization and readability.
- Terraform does not depend on files being executed sequentially.
- Terraform builds a dependency graph based on resource references.
- You can reference a variable, local, resource, or output defined in another ".tf" file in the same directory.
- File naming does not determine resource creation order.

For example:

# vpc.tf

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

The variable can be defined in another file:

# variables.tf

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

Terraform understands the relationship automatically.

Key Concept

Multiple .tf files
        ↓
Terraform combines configuration
        ↓
Terraform analyzes references
        ↓
Dependency Graph
        ↓
Terraform determines creation/update order

Therefore, you should not rely on alphabetical file order for execution.

---

2. Recommended Terraform File Structure

A clean Terraform project can be organized like this:

project-root/
│
├── backend.tf           # Backend configuration
├── versions.tf          # Terraform and provider versions
├── provider.tf          # Provider configurations
│
├── variables.tf         # Input variable definitions
├── locals.tf            # Local value definitions
│
├── main.tf              # Main/common resources
├── vpc.tf               # VPC and networking resources
├── security.tf          # Security groups, NACLs, IAM
├── compute.tf           # EC2, Auto Scaling, etc.
├── storage.tf           # S3, EBS, EFS
├── database.tf          # RDS, DynamoDB
│
├── outputs.tf           # Output definitions
├── terraform.tfvars     # Variable values
│
├── .gitignore
└── README.md            # Documentation

The exact structure can vary depending on the project size and team conventions.

---

3. File Responsibilities

backend.tf

Contains Terraform backend configuration.

Example:

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

Keeping this separate from the backend makes the configuration easier to understand.

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

variables.tf

Contains input variable definitions.

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
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

4. locals.tf

Local values are useful for reusable expressions and naming conventions.

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

Locals help avoid repeating the same expressions throughout the configuration.

---

5. vpc.tf

Networking-related resources can be grouped into "vpc.tf".

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

# Route Table for Public Subnets
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

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

---

6. storage.tf

Storage resources can be grouped together.

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name

  tags = merge(local.common_tags, {
    Name        = local.bucket_name
    Purpose     = "General storage"
    Environment = var.environment
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

---

7. outputs.tf

Outputs expose useful information after Terraform creates resources.

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

8. terraform.tfvars

"terraform.tfvars" contains values for input variables.

# Project Configuration
project_name = "aws-terraform-course"
environment  = "staging"
region       = "us-east-1"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Tags
tags = {
  Owner      = "DevOps-Team"
  Department = "Engineering"
  CostCenter = "Engineering-001"
  Project    = "TerraformLearning"
}

Important

The value assigned to "environment" must match the validation rule.

If validation contains:

contains(["dev", "staging", "production"], var.environment)

then this is invalid:

environment = "demo"

Use:

environment = "staging"

or modify the validation rule to allow "demo".

---

9. File Organization Principles

1. Separation of Concerns

Keep logically different responsibilities in different files.

vpc.tf       → Networking
security.tf  → Security
compute.tf   → Compute
storage.tf   → Storage
database.tf  → Databases

---

2. Logical Grouping

Group related resources together.

For example:

vpc.tf
├── VPC
├── Internet Gateway
├── Subnets
├── Route Tables
└── Route Associations

---

3. Consistent Naming

Use clear and predictable file names.

Good:

vpc.tf
security.tf
compute.tf
database.tf
storage.tf

Avoid:

stuff.tf
new.tf
test2.tf
final-final.tf
misc.tf

---

4. Keep Files Manageable

Avoid creating extremely large files.

For example, instead of:

main.tf
└── 2,000+ lines

split resources logically:

vpc.tf
security.tf
compute.tf
database.tf
storage.tf

There is no strict Terraform requirement that files must be below a particular line count. The goal is maintainability and readability.

---

5. Use Modules for Reusability

If the same infrastructure is required across multiple projects or environments, consider creating a Terraform module.

Example:

modules/
├── vpc/
├── security/
├── compute/
└── database/

A module can then be reused:

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"
}

---

10. Environment-Specific Structure

For larger projects, environments can be separated.

terraform/
│
├── environments/
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

This approach allows each environment to have its own configuration and state.

---

11. Service-Based Structure

Another approach is organizing infrastructure according to AWS services or functions.

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

This is useful when the infrastructure becomes large.

---

12. Terraform Dependency Model

Terraform automatically understands dependencies.

Example:

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

A subnet references the VPC:

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

Terraform sees:

aws_vpc.main
      ↓
aws_subnet.public

Therefore, Terraform knows that the VPC must exist before the subnet.

This is called an implicit dependency.

You can also explicitly define dependencies using:

depends_on = [
  aws_vpc.main
]

but explicit dependencies should only be used when Terraform cannot determine the dependency automatically.

---

13. Commands for Testing

After reorganizing the files:

Initialize Terraform

terraform init

Format the configuration

terraform fmt -recursive

Validate the configuration

terraform validate

Review the execution plan

terraform plan

Apply the configuration

terraform apply

Destroy resources when finished

terraform destroy

---

14. Recommended Workflow

A typical Terraform workflow is:

Create / modify .tf files
        ↓
terraform fmt
        ↓
terraform init
        ↓
terraform validate
        ↓
terraform plan
        ↓
Review changes
        ↓
terraform apply
        ↓
Verify AWS resources

For production environments, "terraform plan" should generally be reviewed before applying changes.

---

15. Common File Organization Mistakes

Mistake 1: Everything in main.tf

main.tf
└── 2,000 lines of Terraform

This makes navigation and maintenance difficult.

---

Mistake 2: Inconsistent Naming

network.tf
vpc-final.tf
newnetwork.tf
network2.tf

Use predictable names instead:

vpc.tf
security.tf
compute.tf
storage.tf

---

Mistake 3: Mixing Unrelated Resources

For example, putting:

VPC
RDS
IAM
S3
EC2

randomly into the same file makes the configuration harder to understand.

---

Mistake 4: No Documentation

Include:

README.md

Document:

- What the infrastructure creates
- Required variables
- AWS regions
- Deployment commands
- Backend requirements
- Environment information
- Important dependencies

---

Mistake 5: Overengineering

Do not create a complicated directory structure for a small Terraform project.

For a small project:

terraform/
├── provider.tf
├── variables.tf
├── locals.tf
├── vpc.tf
├── storage.tf
└── outputs.tf

may be sufficient.

For a large organization:

environments/
modules/
networking/
security/
compute/
data/

may be appropriate.

The structure should match the size and complexity of the infrastructure.

---

16. Important Interview Points

Question: Does Terraform execute ".tf" files alphabetically?

Answer:

No. Terraform loads the configuration from all ".tf" files in the working directory and evaluates them as a single configuration. Terraform determines resource relationships through its dependency graph rather than relying on filename order.

Question: Does the filename affect Terraform functionality?

Generally, no. File names are primarily used to organize the configuration.

Question: Can a resource in "vpc.tf" reference a variable from "variables.tf"?

Yes.

# vpc.tf
cidr_block = var.vpc_cidr

Terraform can access the variable regardless of which ".tf" file defines it.

Question: Why split Terraform into multiple files?

To improve:

- Readability
- Maintainability
- Team collaboration
- Troubleshooting
- Code navigation
- Separation of concerns

Question: When should you use modules?

Use modules when infrastructure components need to be reused, standardized, or maintained independently.

---

17. Final Recommended Structure

For a practical AWS DevOps project:

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

Core principle

Terraform files
      ↓
Single configuration
      ↓
Terraform dependency graph
      ↓
Correct resource ordering

File structure is for humans; dependency graphs are for Terraform.