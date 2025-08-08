resource "aws_instance" "roboshop_instance" {
  count = length(var.instances)
  ami = var.ami_id
  instance_type = lookup(var.instance_type, terraform.workspace)
  #lookup is function it will var from instance_type and matches with the name as terraform.workspace
  vpc_security_group_ids = [ aws_security_group.allow-all.id ]

  tags = merge( 
    var.common_tags,
  {
   Name = "${var.project}-${var.instances[count.index]}-${terraform.workspace}" # robshop-instance-dev or robshop-instance-prod.
   component = "${var.instances[count.index]}"
   enviorment = terraform.workspace
  }
  )

}
resource "aws_security_group" "allow-all" {
  name        = "${var.project}-${var.sg_name}-${terraform.workspace}"
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
    Name = "${var.project}-${var.sg_tags}-${terraform.workspace}"
  }
  )
}






# ======================================================
# Terraform Workspace Commands
# ======================================================
# Workspaces allow creating multiple environments (QA, DEV, PROD) from the same configuration
# Each workspace maintains its own state file, allowing for environment isolation
#
# Key Workspace Commands:
#
# terraform workspace show
# - Shows the name of the current active workspace
#
# terraform workspace list
# - Lists all available workspaces in the current configuration
#
# terraform workspace new dev
# - Creates a new workspace named "dev"
# - Automatically switches to the new workspace
#
# terraform workspace select dev
# - Switches to an existing workspace named "dev"
#
# terraform workspace delete qa
# - Deletes the "qa" workspace (workspace must be empty/unused)
#
# Note: In this configuration, we reference the current workspace using:
# terraform.workspace
# This allows us to dynamically set resources based on the environment
# Example: instance_type = lookup(var.instance_type, terraform.workspace)

# When using workspaces:
# - All configuration files are shared across environments
# - Each workspace has its own state file in terraform.tfstate.d/<workspace_name>/
# - You switch environments with `terraform workspace select <workspace_name>`
# - Resource naming and configuration varies based on terraform.workspace variable
# ======================================================




