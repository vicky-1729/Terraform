output "vpc_id"{
   value =  aws_vpc.main.id
}

output "public_subnet_ids"{
    value = aws_subnet.public[*].id
}

output "private_subnet_ids"{
    value = aws_subnet.private[*].id
}

output "database_subnet_ids"{
    value = aws_subnet.database[*].id
}

output "vpc_sg_id"{
    value = aws_vpc.main.default_security_group_id
}