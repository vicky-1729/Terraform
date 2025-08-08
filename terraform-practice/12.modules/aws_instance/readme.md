# AWS EC2 Instance Terraform Module

A Terraform module to provision AWS EC2 instances with configurable parameters.

## Features

- Creates an AWS EC2 instance with customizable settings
- Supports security group associations
- Configurable instance type, AMI, and tags
- Simple interface with sensible defaults

## Usage

```terraform
module "web_server" {
  source        = "git::https://github.com/vicky-1729/Devops.git//Terraform/practice/12.modules/aws_instance?ref=main"
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  sg_ids        = [module.sg.sg_id]
  instance_tags = {
    Name = "web-server"
    Environment = "dev"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami | The AMI ID to use for the instance | `string` | n/a | yes |
| instance_type | The type of instance to start | `string` | `"t2.micro"` | no |
| sg_ids | A list of security group IDs to associate with | `list(string)` | n/a | yes |
| instance_tags | A map of tags to assign to the instance | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the created EC2 instance |
| private_ip | Private IP address of the EC2 instance |
| public_ip | Public IP address of the EC2 instance |

## Example with User Data

```terraform
module "app_server" {
  source        = "git::https://github.com/vicky-1729/Devops.git//Terraform/practice/12.modules/aws_instance?ref=main"
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.small"
  sg_ids        = [module.app_sg.sg_id]
  instance_tags = {
    Name = "app-server"
    Environment = "prod"
    Project = "roboshop"
  }
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > /var/www/html/index.html
    service httpd start
    chkconfig httpd on
  EOF
}
```

## License

MIT