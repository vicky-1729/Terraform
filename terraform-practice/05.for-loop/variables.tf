variable "ami_id" {
  type    = string
  default = "ami-09c813fb71547fc4f"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "instance_tags" {
  default = {
    Name = "vs-vicky-instance"
  }
}

variable "sg_name" {
  type    = string
  default = "allow-all"
}

variable "sg_description" {
  type    = string
  default = "allow - inbound and outbound"
}

variable "from_port" {
  type    = number
  default = 0
}

variable "to_port" {
  type    = number
  default = 0
}

variable "protocol" {
  type    = string
  default = "-1"
}

variable "sg_tags" {
  type    = string
  default = "vs-allow"
}

variable "instances" {
  default = [
    {
      mongodb  = "t3.micro" # each keyword is assigned for every iteration. you will get each.key and each.value
      redis    = "t3.micro"
      mysql    = "t3.small"
      rabbitmq = "t3.micro"
    }
  ]
}