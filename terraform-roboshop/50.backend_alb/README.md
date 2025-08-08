# Backend Application Load Balancer (ALB) Module

## Overview
This module provisions an internal Application Load Balancer (ALB) for backend services in the RoboShop e-commerce infrastructure. The ALB is deployed in private subnets and handles traffic distribution for backend microservices.

## Architecture

### Components
- **Internal ALB**: Application Load Balancer in private subnets
- **Route53 Record**: DNS record for backend services access
- **Security Groups**: Dedicated security group for ALB traffic control
- **Target Groups**: Will be configured for each backend service

### Network Configuration
- **Type**: Internal (private)
- **Subnets**: Private subnets only
- **Security**: Uses dedicated backend ALB security group
- **DNS**: Registered with Route53 for service discovery

## Resources Created

### 1. Application Load Balancer
```hcl
module "backend_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"
  
  name               = "${var.project}-${var.environment}-backend-alb"
  load_balancer_type = "application"
  vpc_id             = local.vpc_id
  subnets            = local.private_subnet_ids
  internal           = true
  security_groups    = [local.backend_alb_sg_id]
}
```

### 2. Route53 DNS Record
```hcl
resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name    = "backend-alb.${var.zone_name}"
  type    = "A"
  
  alias {
    name                   = module.backend_alb.dns_name
    zone_id                = module.backend_alb.zone_id
    evaluate_target_health = true
  }
}
```

## Input Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| project | Project name | string | "roboshop" |
| environment | Environment name | string | "dev" |
| zone_id | Route53 hosted zone ID | string | - |
| zone_name | Route53 zone name | string | - |

## Data Sources

| Data Source | Description | SSM Parameter |
|-------------|-------------|---------------|
| private_subnet_ids | Private subnet IDs | /${project}/${environment}/private_subnet_ids |
| vpc_id | VPC ID | /${project}/${environment}/vpc_id |
| backend_alb_sg_id | Backend ALB security group ID | /${project}/${environment}/backend_alb_sg_id |

## Outputs

| Output | Description |
|--------|-------------|
| backend_alb_dns_name | DNS name of the backend ALB |
| backend_alb_zone_id | Zone ID of the backend ALB |
| backend_alb_arn | ARN of the backend ALB |

## Security Configuration

### Security Group Rules
The backend ALB uses a dedicated security group with the following rules:
- **Inbound**: HTTP/HTTPS traffic from frontend services and API Gateway
- **Outbound**: Traffic to backend services on their respective ports

### SSL/TLS
- SSL termination at ALB level
- Backend communication can be HTTP (internal network)
- Certificate management through ACM

## Target Groups (Future Implementation)

The following target groups will be configured for backend services:
- **Catalogue Service**: Port 8080
- **User Service**: Port 8080
- **Cart Service**: Port 8080
- **Shipping Service**: Port 8080
- **Payment Service**: Port 8080

## Health Checks

### ALB Health Checks
- **Path**: `/health` or service-specific health endpoints
- **Protocol**: HTTP
- **Port**: Service port (typically 8080)
- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy Threshold**: 2
- **Unhealthy Threshold**: 5

## Monitoring and Logging

### CloudWatch Metrics
- Request count
- Target response time
- HTTP error rates
- Healthy/unhealthy target counts

### Access Logging
- S3 bucket for ALB access logs
- Log format: ELB access log format
- Retention policy: 30 days

## Dependencies

### Required Resources
1. **VPC Module** (00.vpc): VPC and subnets
2. **Security Groups Module** (10.security_groups): Backend ALB security group
3. **Route53 Hosted Zone**: For DNS registration

### Dependency Chain
```
VPC → Security Groups → Backend ALB
```

## Deployment Instructions

### Prerequisites
1. VPC infrastructure deployed
2. Security groups configured
3. Route53 hosted zone available

### Deployment Steps
```bash
# Navigate to backend ALB directory
cd 50.backend_alb

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```

### Verification
```bash
# Check ALB status
aws elbv2 describe-load-balancers --names roboshop-dev-backend-alb

# Verify DNS record
nslookup backend-alb.yourdomain.com

# Check security group association
aws elbv2 describe-load-balancers --names roboshop-dev-backend-alb \
  --query 'LoadBalancers[0].SecurityGroups'
```

## Best Practices

### Performance
- Use application-aware routing
- Configure sticky sessions if needed
- Enable connection draining
- Optimize health check intervals

### Security
- Use dedicated security groups
- Implement least privilege access
- Enable access logging
- Use SSL/TLS for sensitive data

### Cost Optimization
- Use appropriate instance types for targets
- Configure auto-scaling for targets
- Monitor and optimize health check frequency
- Use reserved capacity when applicable

## Troubleshooting

### Common Issues
1. **Health Check Failures**
   - Verify target service health endpoints
   - Check security group rules
   - Confirm target registration

2. **DNS Resolution Issues**
   - Verify Route53 record configuration
   - Check hosted zone settings
   - Confirm ALB DNS name

3. **Connection Timeouts**
   - Review security group rules
   - Check target service availability
   - Verify network ACLs

### Debugging Commands
```bash
# Check ALB health
aws elbv2 describe-target-health --target-group-arn <arn>

# View ALB attributes
aws elbv2 describe-load-balancer-attributes --load-balancer-arn <arn>

# Check listeners
aws elbv2 describe-listeners --load-balancer-arn <arn>
```

## Integration with Other Services

### Frontend Integration
- Frontend services connect via internal DNS
- API Gateway routes traffic through ALB
- CDN caching for static content

### Database Integration
- Backend services connect to databases
- Connection pooling at service level
- Database security groups allow ALB subnet access

### Monitoring Integration
- CloudWatch alarms for ALB metrics
- ELK stack for log aggregation
- Prometheus for custom metrics

## Future Enhancements

### Planned Features
1. **Auto Scaling**: Target group auto-scaling
2. **Blue-Green Deployment**: Support for zero-downtime deployments
3. **Circuit Breakers**: Service mesh integration
4. **Rate Limiting**: Request throttling
5. **Caching**: Application-level caching

### Automation
- CI/CD pipeline integration
- Automated health checks
- Infrastructure as Code workflows
- Disaster recovery automation

---

**Note**: This ALB serves as the central routing point for all backend microservices in the RoboShop application. Ensure proper target group configuration for each service deployment.
- `local.tf` - Local values and common tags
- `outputs.tf` - ALB information outputs
- `provider.tf` - Provider and Terraform configuration

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Update `terraform.tfvars` with your values if needed

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

- **Load Balancer Type**: Application Load Balancer (ALB)
- **Scheme**: Internal (private subnets only)
- **Subnets**: Deployed in private subnets
- **Security Group**: Uses existing security group from SSM parameter

## Dependencies

This configuration depends on:
- VPC resources (via SSM parameter: `/${project}/${environment}/vpc_id`)
- Private subnet IDs (via SSM parameter: `/${project}/${environment}/private_subnet_ids`)
- Backend ALB security group (via SSM parameter: `/${project}/${environment}/backend_alb_sg_id`)

## Outputs

- `backend_alb_id` - Load balancer ID
- `backend_alb_arn` - Load balancer ARN
- `backend_alb_dns_name` - DNS name for internal access
- `backend_alb_zone_id` - Route 53 hosted zone ID
- `backend_alb_target_group_arns` - Target group ARNs

## Target Groups

The ALB module creates target groups that can be used by backend services. These target groups can be referenced in your application server configurations to register instances.

## Security

- Internal load balancer (not internet-facing)
- Uses security groups to control access
- Only accessible from within the VPC
- Frontend servers can access via the security group rules
