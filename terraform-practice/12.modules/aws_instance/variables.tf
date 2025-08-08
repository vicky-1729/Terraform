variable instance_tags{
    type = map(string)
}
variable sg_ids {
    type = list(string)
}
variable instance_type{
    #default = "t2.micro"
}
variable ami{
    #default = "ami-09c813fb71547fc4f"
}
variable "subnet_id"{
   # default
}