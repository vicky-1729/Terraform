# Creates a VPC Peering Connection between the default VPC and this custom VPC, with DNS resolution enabled and auto-accept. Only created if peering is required.
resource "aws_vpc_peering_connection" "default" {
  # Only create if peering is required
  count = var.is_peering_requried ? 1 : 0

  # The VPC ID of the peer (default VPC)
  peer_vpc_id   = data.aws_vpc.default.id # requestor
  # The VPC ID of this module's VPC
  vpc_id        = aws_vpc.main.id # acceptor

  # Allow DNS resolution from the accepter side
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  # Allow DNS resolution from the requester side
  requester {
    allow_remote_vpc_dns_resolution = true
  }

  # Automatically accept the peering connection
  auto_accept = true

  # Merge custom and common tags for the peering connection
  tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.env}-default"
    }
  )
}

# Adds a route in the public route table to allow traffic to the peer VPC via the peering connection. Only created if peering is required.
resource "aws_route" "public_peering" {
  # Only create if peering is required
  count = var.is_peering_requried ? 1 : 0
  # Use the public route table
  route_table_id            = aws_route_table.public.id
  # Destination is the peer VPC's CIDR block
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  # Use the created peering connection
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# Adds a route in the private route table to allow traffic to the peer VPC via the peering connection. Only created if peering is required.
resource "aws_route" "private_peering" {
  count = var.is_peering_requried ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# Adds a route in the DB route table to allow traffic to the peer VPC via the peering connection. Only created if peering is required.
resource "aws_route" "db_peering" {
  count = var.is_peering_requried ? 1 : 0
  route_table_id            = aws_route_table.db.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# Adds a route in the default VPC's main route table to allow traffic to this VPC via the peering connection. Only created if peering is required.
resource "aws_route" "default_peering" {
  count = var.is_peering_requried ? 1 : 0
  # Main route table of the default VPC
  route_table_id            = data.aws_route_table.main.id
  # Destination is this VPC's CIDR block
  destination_cidr_block    = var.cidr_block
  # Use the created peering connection
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}