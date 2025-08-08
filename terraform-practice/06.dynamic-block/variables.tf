variable "ami_id" {
    type = string
    default = "ami-09c813fb71547fc4f"
}

variable "instance_type"{
    default = "t3.micro"
}

variable "instance_tags"{
    default = {
        Name = "vs-vicky-instance"
    }
}

variable "sg_name" {
    type = string
    default = "allow-all"
}

variable "sg_description" {
    type = string
    default = "allow - inbound and outbound"
}

variable "from_port" {
    type = number
    default = 0
}

variable "to_port" {
    type = number
    default = 0
}

variable "protocol"{
    type = string
    default = "-1"
}

variable "sg_tags" {
    type = string
    default = "vs-allow"
}
variable "ingress" {
 
  default = [
    { from_port = 80,   to_port = 80 },
    { from_port = 8080, to_port = 8080 },
    { from_port = 0,    to_port = 0 }
  ]
}