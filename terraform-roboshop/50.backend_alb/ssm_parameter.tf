resource "aws_ssm_parameter" "backend_alb_arn" {
    name  = "/${var.project}/${var.environment}/backend_alb_arn"
    type  = "String"
    value = module.backend_alb.arn
}

resource "aws_ssm_parameter" "backend_alb_dns_name" {
    name  = "/${var.project}/${var.environment}/backend_alb_dns_name"
    type  = "String"
    value = module.backend_alb.dns_name
}

resource "aws_ssm_parameter" "backend_alb_id" {
    name  = "/${var.project}/${var.environment}/backend_alb_id"
    type  = "String"
    value = module.backend_alb.id
}