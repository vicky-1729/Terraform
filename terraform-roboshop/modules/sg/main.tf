# Create security group with outbound traffic allowed
resource "aws_security_group" "sg" {
  name        = "${var.project}-${var.environment}-${var.sg_name}"
  description = var.sg_desc
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    var.sg_tags,
    {
      # roboshop-dev-sg_name
      Name = "${var.project}-${var.environment}-${var.sg_name}"
    }
  )
}

# Allow all outbound traffic
resource "aws_security_group_rule" "outbound_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
  description       = "Allow all outbound traffic"
}
