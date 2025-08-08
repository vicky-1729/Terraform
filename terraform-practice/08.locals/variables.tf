variable "project_name"{
    default = "roboshop"
}

variable "env"{
    default = "dev"
}

variable "component"{
    default = "cart"
}

variable "common_tags"{
    default = {
        Project = "roboshop"
        Terraform = "true"
    }
}
# variable "all_names"{
#     default = "${var.project_name}-${var.env}-${var.component}"
# }
# output :Error: Variables not allowed