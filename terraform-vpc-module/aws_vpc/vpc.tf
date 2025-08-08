resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = merge(
    local.common_tags,{
        Name="${var.project}-${var.env}"
    }
  )
}
  #IGW creation as roboshop-dev
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # IGW directly added to the vpc

  tags = merge(
    var.igw_tags,
    local.common_tags,{
        Name = "${var.project}-${var.env}-IGW"

  })
}
  #roboshop-dev-public-us-east-1a and 1b 

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index] # create mutliple subnets it will work 
  availability_zone = local.az_zones[count.index]
  map_public_ip_on_launch = "true"
  tags = merge(
    var.public_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.env}-public-${local.az_zones[count.index]}"
    }
  )
}

#roboshop-dev-private-us-east-1a and 1b

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = local.az_zones[count.index]

  tags = merge(
    var.private_tags,
   local.common_tags,{
    Name = "${var.project}-${var.env}-private-${local.az_zones[count.index]}"
  })
}

#roboshop-dev-db-us-east-1a and 1b

resource "aws_subnet" "db" {
  count = length(var.db_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.db_subnet_cidr[count.index]
  availability_zone = local.az_zones[count.index]

  tags = merge(
   var.db_tags,
   local.common_tags,{
    Name = "${var.project}-${var.env}-db-${local.az_zones[count.index]}"
  })
}

#createing an elastic ip

resource "aws_eip" "main" {
  domain   = "vpc"
  tags = merge(
   var.eip_tags,
   local.common_tags,{
    Name = "${var.project}-${var.env}"
  })

}

#create nat-gateway

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  tags=merge(
    var.natgateway_tags,
    local.common_tags,
    {
      Name= "${var.project}-${var.env}-NGW"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# create public route table and private route and db route

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

tags=merge(
    var.public_route_tags,
    local.common_tags,
    {
      Name= "${var.project}-${var.env}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

tags=merge(
    var.private_route_tags,
    local.common_tags,
    {
      Name= "${var.project}-${var.env}-private"
    }
  )
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

tags=merge(
    var.db_route_tags,
    local.common_tags,
    {
      Name= "${var.project}-${var.env}-db"
    }
  )
}

# create public route and private route and db route
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
}
resource "aws_route" "db" {
  route_table_id            = aws_route_table.db.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
}

#subnet assocation for piblic and private and db

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "db" {
  count = length(var.db_subnet_cidr)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}