provider "aws" {
  region = "us-east-1" # or your preferred region
}
resource "aws_instance" "roboshop_instance"{
  count = 4
  ami = "ami-09c813fb71547fc4f"
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.allow-all.id ]
  
  tags = {
   
     Name =  var.instances[count.index]
   
  }


}
resource "aws_security_group" "allow-all" {
  name        = "allow-all"
  description = "allow - inbound and outbound"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "allow-vs"
  }
}
