module "backend_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"
  
  name               = "${var.project}-${var.environment}-backend-alb"
  load_balancer_type = "application"
  vpc_id             = local.vpc_id
  subnets            = local.private_subnet_ids
 
  # ALB Configuration
  internal = true  # Since it's in private subnets
  
  # Security Group
  create_security_group = false
  security_groups       = [local.backend_alb_sg_id]
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-backend-alb"
    }
  )
}

resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name    = "*.backend_alb.${var.zone_name}" # all.backend_alb.ts.cloudguru.in
  type    = "A"

  alias {
    name                   = module.backend_alb.zone_name
    zone_id                = module.backend_alb.zone_id
    evaluate_target_health = true
  }
}
