output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet_ids" {
    value = aws_subnet.public[*].id
    description = "List of public subnet IDs"
}

output "private_subnet_ids" {
    value = aws_subnet.private[*].id
    description = "List of private subnet IDs"
}

output "public_subnet_cidr_blocks" {
    value = aws_subnet.public[*].cidr_block
    description = "List of CIDR blocks for public subnets"
}

output "private_subnet_cidr_blocks" {
    value = aws_subnet.private[*].cidr_block
    description = "List of CIDR blocks for private subnets"
}