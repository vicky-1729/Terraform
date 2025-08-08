# Create security group for frontend servers (web tier)
# This SG will allow incoming traffic to frontend applications
module "frontend"{
    source = "../modules/sg"
    
    # Required Variables
    vpc_id      = local.vpc_id
    project     = var.project
    environment = var.environment
    sg_name     = var.frontend_sg_name
    sg_desc     = var.frontend_sg_desc
    
    # Optional Custom Tags
    sg_tags = {
      Name = "${var.project}-${var.environment}-${var.frontend_sg_name}"
    }
}

# Create security group for bastion host (jump server)
# This SG allows SSH access from internet to bastion for secure server access
module "bastion"{
    source = "../modules/sg"
    
    # Required Variables
    vpc_id      = local.vpc_id
    project     = var.project
    environment = var.environment
    sg_name     = var.bastion_sg_name
    sg_desc     = var.bastion_sg_desc
}
# Create security group for VPN server
# This SG allows VPN traffic and secure remote access to the infrastructure
module "vpn" {
  source = "../modules/sg"

  vpc_id      = local.vpc_id
  project     = var.project
  environment = var.environment
  sg_name     = var.vpn_sg_name
  sg_desc     = var.vpn_sg_desc
}
# Create security group for backend Application Load Balancer (ALB)
# This SG allows internal traffic routing to backend services
module "backend_alb" {
  source = "../modules/sg"

  vpc_id      = local.vpc_id
  project     = var.project
  environment = var.environment
  sg_name     = var.backend_alb_sg_name
  sg_desc     = var.backend_alb_sg_desc
}

# Create security group for MongoDB database servers
# This SG controls access to MongoDB instances in the private subnet
module "mongodb"{
   source = "../modules/sg"

   vpc_id      = local.vpc_id
   project     = var.project
   environment = var.environment
   sg_name     = var.mongodb_sg_name
   sg_desc     = var.mongodb_sg_desc
}

module "redis"{
  source = "../modules/sg"

  vpc_id = local.vpc_id
  project = var.project
  environment = var.environment 
  sg_name     = var.redis_sg_name
  sg_desc     = var.redis_sg_desc
}
module "mysql"{
  source = "../modules/sg"

  vpc_id = local.vpc_id
  project = var.project
  environment = var.environment 
  sg_name     = var.mysql_sg_name
  sg_desc     = var.mysql_sg_desc
}
module "rabbitmq"{
  source = "../modules/sg"

  vpc_id = local.vpc_id
  project = var.project
  environment = var.environment 
  sg_name     = var.rabbitmq_sg_name
  sg_desc     = var.rabbitmq_sg_desc
}
#catalogue

module "catalogue" {
  source = "../modules/sg"

  vpc_id = local.vpc_id
  project = var.project
  environment = var.environment
  sg_name = var.catalogue_sg_name
  sg_desc = var.catalogue_sg_desc
}



# Security Group Rules Section
# ===========================

# Allow SSH access to frontend servers from anywhere (port 22)
# This enables direct SSH access to frontend instances for maintenance
resource "aws_security_group_rule" "frontend_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend.sg_id
}

# Allow SSH access to bastion host from anywhere (port 22)
# This is the entry point for secure access to private resources
resource "aws_security_group_rule" "bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}


# Allow HTTP traffic from bastion to backend ALB (port 80)
# This enables bastion host to access backend services through the load balancer
resource "aws_security_group_rule" "backend_alb_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # Source via proxy sg_id
  security_group_id = module.backend_alb.sg_id # Destination
}





# Allow HTTP traffic from VPN to backend ALB (port 80)
# This enables VPN users to access backend services through the load balancer
resource "aws_security_group_rule" "backend_alb_80_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # Source via proxy sg_id
  security_group_id = module.backend_alb.sg_id # Destination
}
# VPN Server Security Group Rules
# ================================

# Allow OpenVPN UDP traffic (port 1194)
# This is the main OpenVPN protocol port for VPN connections
resource "aws_security_group_rule" "vpn_1194" {
  type                     = "ingress"
  from_port                = 1194
  to_port                  = 1194
  protocol                 = "udp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = module.vpn.sg_id # Destination
}
# Allow HTTPS traffic for VPN web interface (port 443)
# This enables secure web access to VPN management interface
resource "aws_security_group_rule" "vpn_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = module.vpn.sg_id # Destination
}
# Allow OpenVPN Access Server admin web UI (port 943)
# This port is used for OpenVPN Access Server administrative interface
resource "aws_security_group_rule" "vpn_943" {
  type                     = "ingress"
  from_port                = 943
  to_port                  = 943
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = module.vpn.sg_id # Destination
}
# Allow OpenVPN Access Server client web UI (port 953)
# This port is used for OpenVPN client download and user interface
resource "aws_security_group_rule" "vpn_953" {
  type                     = "ingress"
  from_port                = 953
  to_port                  = 953
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = module.vpn.sg_id # Destination
}
# Allow SSH access to VPN server (port 22)
# This enables SSH access to VPN server for maintenance and configuration
resource "aws_security_group_rule" "vpn_22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = module.vpn.sg_id # Destination
}

# MongoDB Security Group Rules
# =============================

# Allow MongoDB access from VPN to MongoDB servers
# This enables VPN users to connect to MongoDB database
resource "aws_security_group_rule" "mongodb_from_vpn" {
  count                    = length(var.mongodb_inbound_ports)
  type                     = "ingress"
  from_port                = var.mongodb_inbound_ports[count.index]
  to_port                  = var.mongodb_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id # Source via VPN sg_id
  security_group_id        = module.mongodb.sg_id # Destination
}

# Allow MongoDB access from bastion to MongoDB servers
# This enables bastion host to connect to MongoDB database for maintenance
resource "aws_security_group_rule" "mongodb_from_bastion" {
  count                    = length(var.mongodb_inbound_ports)
  type                     = "ingress"
  from_port                = var.mongodb_inbound_ports[count.index]
  to_port                  = var.mongodb_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id # Source via bastion sg_id
  security_group_id        = module.mongodb.sg_id # Destination
}
resource "aws_security_group_rule" "mongodb_from_catalogue" {
  count                    = length(var.mongodb_inbound_ports)
  type                     = "ingress"
  from_port                = var.mongodb_inbound_ports[count.index]
  to_port                  = var.mongodb_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.catalogue.sg_id # Source via bastion sg_id
  security_group_id        = module.mongodb.sg_id # Destination
}
# mysql Security Group Rules
# =============================


resource "aws_security_group_rule" "mysql_from_vpn" {
  count                    = length(var.mysql_inbound_ports)
  type                     = "ingress"
  from_port                = var.mysql_inbound_ports[count.index]
  to_port                  = var.mysql_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id # Source via VPN sg_id
  security_group_id        = module.mysql.sg_id # Destination
}


resource "aws_security_group_rule" "mysql_from_bastion" {
  count                    = length(var.mysql_inbound_ports)
  type                     = "ingress"
  from_port                = var.mysql_inbound_ports[count.index]
  to_port                  = var.mysql_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id # Source via bastion sg_id
  security_group_id        = module.mysql.sg_id # Destination
}
# rabbitmq Security Group Rules
# =============================

resource "aws_security_group_rule" "rabbitmq_from_vpn" {
  count                    = length(var.rabbitmq_inbound_ports)
  type                     = "ingress"
  from_port                = var.rabbitmq_inbound_ports[count.index]
  to_port                  = var.rabbitmq_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id # Source via VPN sg_id
  security_group_id        = module.rabbitmq.sg_id # Destination
}


resource "aws_security_group_rule" "rabbitmq_from_bastion" {
  count                    = length(var.rabbitmq_inbound_ports)
  type                     = "ingress"
  from_port                = var.rabbitmq_inbound_ports[count.index]
  to_port                  = var.rabbitmq_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id # Source via bastion sg_id
  security_group_id        = module.rabbitmq.sg_id # Destination
}
# redis Security Group Rules
# =============================

resource "aws_security_group_rule" "redis_from_vpn" {
  count                    = length(var.redis_inbound_ports)
  type                     = "ingress"
  from_port                = var.redis_inbound_ports[count.index]
  to_port                  = var.redis_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id # Source via VPN sg_id
  security_group_id        = module.redis.sg_id # Destination
}


resource "aws_security_group_rule" "redis_from_bastion" {
  count                    = length(var.redis_inbound_ports)
  type                     = "ingress"
  from_port                = var.redis_inbound_ports[count.index]
  to_port                  = var.redis_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id # Source via bastion sg_id
  security_group_id        = module.redis.sg_id # Destination
}

#catalogue ports
resource "aws_security_group_rule" "catalogue_from_bastion" {
  count                    = length(var.catalogue_inbound_ports)
  type                     = "ingress"
  from_port                = var.catalogue_inbound_ports[count.index]
  to_port                  = var.catalogue_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id # Source via bastion sg_id
  security_group_id        = module.catalogue.sg_id # Destination
}
resource "aws_security_group_rule" "catalogue_from_vpn" {
  count                    = length(var.catalogue_inbound_ports)
  type                     = "ingress"
  from_port                = var.catalogue_inbound_ports[count.index]
  to_port                  = var.catalogue_inbound_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id # Source via bastion sg_id
  security_group_id        = module.catalogue.sg_id # Destination
}
