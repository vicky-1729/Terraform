# Security Group Outputs
output "frontend_sg_id" {
    description = "ID of the frontend security group"
    value       = module.frontend.sg_id
}

output "bastion_sg_id" {
    description = "ID of the bastion security group"
    value       = module.bastion.sg_id
}

output "backend_alb_sg_id" {
    description = "ID of the backend ALB security group"
    value       = module.backend_alb.sg_id
}
output "vpn_sg_id" {
    description = "ID of the backend ALB security group"
    value       = module.vpn.sg_id
}
