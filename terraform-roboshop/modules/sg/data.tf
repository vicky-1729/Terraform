    data "aws_ssm_parameter" "vpc_id" {
      name = "/${var.project}/${var.environment}/vpc_id"  # Replace with your SSM parameter name
    }