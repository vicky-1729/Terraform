# Local variable for VPC ID - simplifies referencing in other resources
locals {
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}