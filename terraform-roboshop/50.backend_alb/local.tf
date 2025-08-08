locals {
    # Data from SSM parameters
    private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    backend_alb_sg_id = data.aws_ssm_parameter.backend_alb_sg_id.value
    
    common_tags = {
        project = var.project
        environment = var.environment
        terraform = true
    }
}