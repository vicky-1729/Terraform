resource "aws_instance" "roboshop_instance" {
  count = length(var.instances)
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.allow-all.id ]

  tags = merge( 
    var.common_tags,
  {
   Name = "${var.project}-${var.instances[count.index]}-${var.env}" # robshop-instance-dev or robshop-instance-prod.
   component = "${var.instances[count.index]}"
   enviorment = "${var.env}"
  }
  )

}
resource "aws_security_group" "allow-all" {
  name        = "${var.project}-${var.sg_name}-${var.env}"
  description = var.sg_description

  ingress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = var.protocol
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic"
  }

  egress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = var.protocol
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,{
    Name = "${var.project}-${var.sg_tags}-${var.env}"
  }
  )
}

# ======================================================
# Multi-Environment Terraform Commands:
# ======================================================
# terraform init -backend-config=prod/backend.tf
# - Initializes Terraform with backend configuration specific to production environment
# - Sets up where the state file will be stored (S3, local, etc.) based on prod settings
#
# terraform plan -var-file=prod/prod.tfvars 
# - Creates an execution plan using production-specific variable values
# - Shows what changes will be made to the infrastructure without applying them
#
# terraform apply -var-file=prod/prod.tfvars --auto-approve
# - Applies the changes to create/update infrastructure using production configuration
# - --auto-approve skips the confirmation prompt (use with caution)
#
# terraform destroy -var-file=prod/prod.tfvars --auto-approve
# - Destroys all resources created by Terraform in the production environment
# - --auto-approve skips the confirmation prompt (use with caution)