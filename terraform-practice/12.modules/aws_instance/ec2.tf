resource "aws_instance" "this" {
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = var.sg_ids
  tags = var.instance_tags
  subnet_id = var.subnet_id
}