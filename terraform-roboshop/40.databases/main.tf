# ==================================================================================
# DATABASE LAYER CONFIGURATION
# ==================================================================================
# This file provisions the database layer for the RoboShop e-commerce application.
# It includes MongoDB, Redis, MySQL, and RabbitMQ instances with their respective
# Route53 DNS records and automated configuration through bootstrap scripts.
#
# Components:
# - MongoDB: Document database for product catalog
# - Redis: In-memory cache for session management
# - MySQL: Relational database for user and transactional data
# - RabbitMQ: Message broker for asynchronous communication
#
# Each database instance is deployed with:
# - Dedicated security groups for network isolation
# - Automated configuration via bootstrap scripts
# - Route53 DNS records for service discovery
# - Proper tagging for resource management
# ==================================================================================

# ==================================================================================
# MONGODB DATABASE
# ==================================================================================
# MongoDB serves as the primary document database for the RoboShop application,
# storing product catalogs, inventory data, and other document-based information.
# ==================================================================================

# MongoDB EC2 Instance
resource "aws_instance" "mongodb" {
    ami                    = local.ami_id
    instance_type          = "t3.micro"
    vpc_security_group_ids = [local.mongodb_sg_id]
    subnet_id              = local.database_subnet_id
    
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-mongodb"
            Service = "mongodb"
            Type = "database"
        }
    )
}

# MongoDB Route53 DNS Record
# Creates internal DNS record for service discovery
resource "aws_route53_record" "mongodb" {
    zone_id         = var.zone_id
    name            = "mongodb-${var.environment}.${var.zone_name}"
    type            = "A"
    ttl             = 1
    records         = [aws_instance.mongodb.private_ip]
    allow_overwrite = true
}

# MongoDB Configuration Provisioner
# Automatically configures MongoDB service after instance creation
resource "terraform_data" "mongodb" {
    triggers_replace = [
        aws_instance.mongodb.id
    ]
    
    # Upload bootstrap script to the instance
    provisioner "file" {
        source      = "bootstrap.sh"
        destination = "/tmp/bootstrap.sh"
    }

    # SSH connection configuration
    connection {
        type     = "ssh"
        user     = "ec2-user"
        password = "DevOps321"
        host     = aws_instance.mongodb.private_ip
    }

    # Execute MongoDB configuration
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/bootstrap.sh",
            "sudo sh /tmp/bootstrap.sh mongodb ${var.environment}"
        ]
    }
}

# ==================================================================================
# REDIS CACHE
# ==================================================================================
# Redis serves as the in-memory cache and session store for the RoboShop application,
# providing fast access to frequently accessed data and user sessions.
# ==================================================================================

# Redis EC2 Instance
resource "aws_instance" "redis" {
    ami                    = local.ami_id
    instance_type          = "t3.micro"
    vpc_security_group_ids = [local.redis_sg_id]
    subnet_id              = local.database_subnet_id
    
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-redis"
            Service = "redis"
            Type = "cache"
        }
    )
}

# Redis Route53 DNS Record
# Creates internal DNS record for service discovery
resource "aws_route53_record" "redis" {
    zone_id         = var.zone_id
    name            = "redis-${var.environment}.${var.zone_name}"
    type            = "A"
    ttl             = 1
    records         = [aws_instance.redis.private_ip]
    allow_overwrite = true
}

# Redis Configuration Provisioner
# Automatically configures Redis service after instance creation
resource "terraform_data" "redis" {
    triggers_replace = [
        aws_instance.redis.id
    ]
    
    # Upload bootstrap script to the instance
    provisioner "file" {
        source      = "bootstrap.sh"
        destination = "/tmp/bootstrap.sh"
    }

    # SSH connection configuration
    connection {
        type     = "ssh"
        user     = "ec2-user"
        password = "DevOps321"
        host     = aws_instance.redis.private_ip
    }

    # Execute Redis configuration
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/bootstrap.sh",
            "sudo sh /tmp/bootstrap.sh redis ${var.environment}"
        ]
    }
}

# ==================================================================================
# MYSQL DATABASE
# ==================================================================================
# MySQL serves as the relational database for the RoboShop application,
# storing user accounts, order history, and other structured data.
# ==================================================================================

# MySQL EC2 Instance
resource "aws_instance" "mysql" {
    ami                    = local.ami_id
    instance_type          = "t3.micro"
    vpc_security_group_ids = [local.mysql_sg_id]
    subnet_id              = local.database_subnet_id
    
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-mysql"
            Service = "mysql"
            Type = "database"
        }
    )
}

# MySQL Route53 DNS Record
# Creates internal DNS record for service discovery
resource "aws_route53_record" "mysql" {
    zone_id         = var.zone_id
    name            = "mysql-${var.environment}.${var.zone_name}"
    type            = "A"
    ttl             = 1
    records         = [aws_instance.mysql.private_ip]
    allow_overwrite = true
}

# MySQL Configuration Provisioner
# Automatically configures MySQL service after instance creation
resource "terraform_data" "mysql" {
    triggers_replace = [
        aws_instance.mysql.id
    ]
    
    # Upload bootstrap script to the instance
    provisioner "file" {
        source      = "bootstrap.sh"
        destination = "/tmp/bootstrap.sh"
    }

    # SSH connection configuration
    connection {
        type     = "ssh"
        user     = "ec2-user"
        password = "DevOps321"
        host     = aws_instance.mysql.private_ip
    }

    # Execute MySQL configuration
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/bootstrap.sh",
            "sudo sh /tmp/bootstrap.sh mysql"
        ]
    }
}

# ==================================================================================
# RABBITMQ MESSAGE BROKER
# ==================================================================================
# RabbitMQ serves as the message broker for the RoboShop application,
# handling asynchronous communication between microservices.
# ==================================================================================

# RabbitMQ EC2 Instance
resource "aws_instance" "rabbitmq" {
    ami                    = local.ami_id
    instance_type          = "t3.micro"
    vpc_security_group_ids = [local.rabbitmq_sg_id]
    subnet_id              = local.database_subnet_id
    
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-rabbitmq"
            Service = "rabbitmq"
            Type = "message-broker"
        }
    )
}

# RabbitMQ Route53 DNS Record
# Creates internal DNS record for service discovery
resource "aws_route53_record" "rabbitmq" {
    zone_id         = var.zone_id
    name            = "rabbitmq-${var.environment}.${var.zone_name}"
    type            = "A"
    ttl             = 1
    records         = [aws_instance.rabbitmq.private_ip]
    allow_overwrite = true
}

# RabbitMQ Configuration Provisioner
# Automatically configures RabbitMQ service after instance creation
resource "terraform_data" "rabbitmq" {
    triggers_replace = [
        aws_instance.rabbitmq.id
    ]
    
    # Upload bootstrap script to the instance
    provisioner "file" {
        source      = "bootstrap.sh"
        destination = "/tmp/bootstrap.sh"
    }

    # SSH connection configuration
    connection {
        type     = "ssh"
        user     = "ec2-user"
        password = "DevOps321"
        host     = aws_instance.rabbitmq.private_ip
    }

    # Execute RabbitMQ configuration
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/bootstrap.sh",
            "sudo sh /tmp/bootstrap.sh rabbitmq ${var.environment}"
        ]
    }
}

# ==================================================================================
# NOTES:
# ==================================================================================
# 1. All instances use dedicated security groups for network isolation
# 2. Bootstrap script handles service-specific configuration
# 3. Route53 records enable internal service discovery
# 4. All resources are tagged for proper resource management
# 5. Database instances are deployed in dedicated database subnets
# 6. SSH provisioners use password authentication (consider key-based auth for production)
# ==================================================================================
