locals {
   private_subnet_id =  split(",",data.aws_ssm_parameter.private_subnet_ids.values)[0]
   vpn_sg_id = data.aws_ssm_parameter.vpn_sg_id.value
   catalogue_sg_id = data.aws_ssm_parameter.catalogue_sg_id
   ami_id = data.aws_ami.joindevops.id
   vpc_id = data.aws_ssm_parameter.vpc_id
   common_tags = {
    project = roboshop
    environment = dev
    terraform = true
   }
}