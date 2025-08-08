# Create VPC with DNS hostnames enabled
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_blocks
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = merge(
    local.common_tags,
    var.vpc_tags,
    {
      # roboshop-dev-vpc
      Name = "${var.project}-${var.environment}-vpc"
    }
  )
}

# Create Internet Gateway for VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.igw_tags,
    {
      # roboshop-dev-igw
      Name = "${var.project}-${var.environment}-igw"
    }
  )
}

# Create public subnets in VPC
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(
    local.common_tags,
    {
      # roboshop-dev-public-us-east-1a
      Name = "${var.project}-${var.environment}-public-${local.availability_zones[count.index]}"
    }
  )
}

# Create private subnets in VPC
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]
  
  tags = merge(
    local.common_tags,
    {
      # roboshop-dev-private-us-east-1a
      Name = "${var.project}-${var.environment}-private-${local.availability_zones[count.index]}"
    }
  )
}

# Create database subnets in VPC
resource "aws_subnet" "database" {
  count             = length(var.db_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]
  
  tags = merge(
    local.common_tags,
    {
      # roboshop-dev-database-us-east-1a
      Name = "${var.project}-${var.environment}-database-${local.availability_zones[count.index]}"
    }
  )
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      # roboshop-dev-nat-eip
      Name = "${var.project}-${var.environment}-eip"
    }
  )
}

# Create NAT Gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = merge(
    local.common_tags,
    var.ngw_tags,
    {
      # roboshop-dev-ngw
      Name = "${var.project}-${var.environment}-ngw"
    }
  )
  
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}
# Create route tables for public, private, and database subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.public_route_tags,
    {
      # roboshop-dev-public-rt
      Name = "${var.project}-${var.environment}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.private_route_tags,
    {
      # roboshop-dev-private-rt
      Name = "${var.project}-${var.environment}-private-rt"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.db_route_tags,
    {
      # roboshop-dev-database-rt
      Name = "${var.project}-${var.environment}-database-rt"
    }
  )
}

# Create routes for public, private, and database route tables
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

# Associate subnets with route tables
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count          = length(var.db_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}