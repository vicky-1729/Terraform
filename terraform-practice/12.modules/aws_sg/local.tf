locals {
    common_tags = {
        project = var.project,
        environment = var.environment,
        Terraform = true

    }
}