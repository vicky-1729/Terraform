variable "cidr_block"{
    default = "10.0.0.0/16"
}
variable "project"{
    type = string
}
variable "env" {
    type = string
}
variable public_subnet_cidr{
    type = list(string)
    
}
variable private_subnet_cidr{
    type = list(string)
}
variable db_subnet_cidr{
    type = list(string)
}
variable "igw_tags"{
    type = map(string)
    default = {}
}
variable "private_tags"{
    type = map(string) #it is mandotroy
    default={} # now it is optional
}
variable "public_tags"{
    type = map(string)
    default={}
}
variable "db_tags"{
    type = map(string)
    default={}
}
variable "eip_tags"{
    type = map(string)
    default={}
}
variable "natgateway_tags"{
    type = map(string)
    default={}
}
variable "public_route_tags"{
    type = map(string)
    default={}
}
variable "private_route_tags"{
    type = map(string)
    default={}
}
variable "db_route_tags"{
    type = map(string)
    default={}
}
variable "vpc_peering_tags"{
    type = map(string)
    default={}
}
variable "is_peering_requried"{
    default = false
}