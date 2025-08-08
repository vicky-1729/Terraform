# Security Group Outputs for use in other modules and resources

# Security Group ID - Most commonly used output
output "sg_id" {
    description = "ID of the security group"
    value       = aws_security_group.sg.id
}


# VPC ID - For validation and cross-reference
output "vpc_id" {
    description = "ID of the VPC where security group is created"
    value       = aws_security_group.sg.vpc_id
}