locals {
    # Get only first 2 availability zones
    availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
    
    # Dynamic tags using variables instead of hardcoded values
    common_tags = {
        project     = var.project
        environment = var.environment
        terraform   = true
    }
}