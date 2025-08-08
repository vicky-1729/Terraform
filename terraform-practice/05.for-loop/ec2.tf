provider "aws" {
  region = "us-east-1" # or your preferred region
}
resource "aws_instance" "roboshop_instance" {
  for_each               = var.instances
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow-all.id]
  tags                   = var.instance_tags
}
resource "aws_security_group" "allow-all" {
  name        = var.sg_name
  description = var.sg_description

  ingress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = var.protocol
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic"
  }

  egress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = var.protocol
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = var.sg_tags
  }

}
