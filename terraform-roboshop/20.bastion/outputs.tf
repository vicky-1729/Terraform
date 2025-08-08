# Bastion Host Outputs
output "bastion_instance_id" {
    description = "ID of the bastion host instance"
    value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
    description = "Public IP address of the bastion host"
    value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
    description = "Private IP address of the bastion host"
    value       = aws_instance.bastion.private_ip
}

output "bastion_public_dns" {
    description = "Public DNS name of the bastion host"
    value       = aws_instance.bastion.public_dns
}

output "bastion_availability_zone" {
    description = "Availability zone of the bastion host"
    value       = aws_instance.bastion.availability_zone
}
