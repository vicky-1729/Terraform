resource "aws_security_group" "sg" {
  name        = var.sg_name
  description = var.sg_desc
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.sg_tags,
    local.common_tags,
    {
        #roboshop-dev-sg_name
    Name = "${var.project}-${var.environment}-${var.sg_name}"
  })
}