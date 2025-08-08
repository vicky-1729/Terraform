data "aws_ami" "latest_AMI_roboshop" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  # Optional: Add owner ID if filtering official or specific AMIs
  # owners = ["your-account-id"]
}

output "AMI" {
  value = data.aws_ami.latest_AMI_roboshop.id
}
