resource "aws_ssm_parameter" "vpc_id" {
  name  = "/roboshop/dev-vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/roboshop/dev-public_subnet_ids"
  type  = "StringList"
  # [1212344,1234144]
  value = join(",", module.vpc.public_subnet_ids)
 # 132145,12345
}
resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/roboshop/dev-private_subnet_ids"
  type  = "StringList"
  # [1212344,1234144]
  value = join(",", module.vpc.private_subnet_ids)
 # 132145,12345
}
