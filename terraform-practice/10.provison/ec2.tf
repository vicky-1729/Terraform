resource "aws_instance" "roboshop_instance" {
  count = length(var.instances)
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.allow-all.id ]

  # Set a tag for the instance name using the corresponding value from instances list
  tags = {
   Name = var.instances[count.index]
  }

  # LOCAL-EXEC PROVISIONER: Runs on the machine executing Terraform (not on the created resource)
  # This adds the private IP of each created instance to an inventory file for later use (e.g., Ansible)
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> inventory"
    # Continue deployment even if this command fails
    on_failure = continue 
  }
  
  # LOCAL-EXEC PROVISIONER: Runs when the instance is destroyed
  # Outputs a message when an instance is destroyed
  provisioner "local-exec"{
    command = "echo 'instance is detsroyed' "
    when = destroy
  }
  
  # CONNECTION BLOCK: Defines how Terraform connects to the instance for provisioning
  connection {
       type        = "ssh"  # Connection type (SSH)
       host        = self.public_ip  # Use the instance's public IP address
       user        = "ec2-user"  # The user to connect as (depends on the AMI)
       password    = "DevOps321"  # WARNING: Hardcoded credentials - use SSH keys for production!
     }

  # REMOTE-EXEC PROVISIONER: Runs commands on the created EC2 instance
  # Install and start Nginx web server on the created instance
  provisioner "remote-exec" {
    inline = [
     "sudo dnf install nginx -y",
     "sudo systemctl start nginx"
    ]
  }
  
  # REMOTE-EXEC PROVISIONER: Runs when the instance is destroyed
  # Stop Nginx gracefully before destroying the instance
  provisioner "remote-exec"{
    when = destroy
    inline = [
      "sudo systemctl stop nginx"  
    ]
  }
}
resource "aws_security_group" "allow-all" {
  name        = var.sg_name
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

  tags = {
    Name = var.sg_tags
  }

}




# # Resource block for AWS EC2 instance
# resource "aws_instance" "example" {
#   ami           = "ami-123456"
#   instance_type = "t2.micro"

#   # SSH connection details for remote access
#   connection {
#     type     = "ssh"
#     host     = self.public_ip
#     user     = "ec2-user"
#     password = "DevOps321"  # Note: Using passwords in code is not recommended for production
#   }

#   # Remote execution provisioner to install and start nginx
#   provisioner "remote-exec" {
#     inline = [
#       "sudo dnf install nginx -y",
#       "sudo systemctl start nginx"
#     ]
#   }

#   # Local execution when instance is created
#   provisioner "local-exec" {
#     command = "echo Instance created"
#   }

#   # Remote execution to stop nginx when instance is destroyed
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [
#       "sudo systemctl stop nginx"
#     ]
#   }

#   # Local execution when instance is destroyed
#   provisioner "local-exec" {
#     when    = destroy
#     command = "echo Instance destroyed"
#   }
# }




