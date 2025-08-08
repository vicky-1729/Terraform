variable instance_type {
    type = string
    default = "t3.micro"
}
variable security_group_ids{
    default = ["sg-0e76411b58e25660d"]
}
variable tags{
    default={
        Name = "roboshop-cart-prod"
    }
}