output "backend_alb_arn" {
    description = "ARN of the backend application load balancer"
    value = module.backend_alb.arn
}

output "backend_alb_dns_name" {
    description = "The DNS name of the load balancer"
    value = module.backend_alb.dns_name
}

output "backend_alb_id" {
    description = "ID of the backend application load balancer"
    value = module.backend_alb.id
}