# 🏰 Bastion Host - SSH Jump Server

## 📋 Overview

The bastion host serves as a secure SSH gateway to access private resources in the RoboShop infrastructure. It's deployed in a public subnet and provides controlled access to private instances following security best practices.

## 🎯 Purpose

- **SSH Gateway**: Secure access point to private resources
- **Security Boundary**: Only entry point to internal infrastructure  
- **Audit Point**: All SSH access logged and monitored
- **Administrative Access**: Management and troubleshooting capabilities

## 🏗️ Architecture

```
Internet → Bastion Host (Public Subnet) → Private Resources
         (SSH Port 22)                   (Internal SSH)
```

### **Access Pattern:**
1. **External Access**: SSH from Internet → Bastion Host (port 22)
2. **Internal Access**: SSH from Bastion → All private instances
3. **Database Access**: Direct connection to MongoDB, Redis, MySQL, RabbitMQ

## 📊 Configuration Details

| Attribute | Value | Purpose |
|-----------|-------|---------|
| **Instance Type** | `t3.micro` | Cost-effective for SSH gateway |
| **AMI** | `RHEL-9-DevOps-Practice` | Pre-configured with DevOps tools |
| **Subnet** | Public Subnet | Internet accessibility |
| **Security Group** | `bastion_sg` | SSH access control from Internet |
| **Public IP** | Auto-assigned | Direct SSH access point |

## 🔒 Security Features

### **Network Security:**
- **Public Subnet**: Accessible from Internet
- **Security Group**: Only SSH (port 22) allowed inbound
- **Outbound**: Full access to internal resources

### **Access Control:**
- **SSH Key**: Required for authentication
- **Source IP**: Can be restricted to specific IP ranges
- **Internal Access**: Can reach all private subnets

## 🚀 Usage

### **SSH to Bastion:**
```bash
# Direct SSH to bastion
ssh -i your-key.pem ec2-user@bastion-public-ip
```

### **SSH Through Bastion (Jump Host):**
```bash
# Direct jump to private instance
ssh -i your-key.pem -J ec2-user@bastion-public-ip ec2-user@private-instance-ip

# Or using ProxyCommand
ssh -i your-key.pem -o ProxyCommand="ssh -W %h:%p -i your-key.pem ec2-user@bastion-public-ip" ec2-user@private-instance-ip
```

### **Database Access Examples:**
```bash
# From bastion, connect to databases
ssh ec2-user@mongodb-private-ip
ssh ec2-user@redis-private-ip  
ssh ec2-user@mysql-private-ip
ssh ec2-user@rabbitmq-private-ip

# Check database services
sudo systemctl status mongod
sudo systemctl status redis
sudo systemctl status mysql
sudo systemctl status rabbitmq-server
```

## 🔗 Dependencies

### **Required Resources:**
- **VPC**: Public subnet from `00.vpc` module
- **Security Group**: `bastion_sg` from `10.security_groups` module
- **AMI**: RHEL-9-DevOps-Practice image

### **SSM Parameters Used:**
- `/roboshop/dev/public_subnet_ids` - For subnet placement
- `/roboshop/dev/bastion_sg_id` - For security group assignment

## 🚀 Deployment

```bash
cd 20.bastion/
terraform init
terraform plan
terraform apply
```

### **Verification:**
```bash
# Get bastion public IP
terraform output bastion_public_ip

# Test SSH connectivity
ssh -i your-key.pem ec2-user@<bastion-public-ip>

# Test internal connectivity (from bastion)
ping mongodb-private-ip
ping redis-private-ip
```

## 📋 Files Structure

```
20.bastion/
├── main.tf        # Bastion instance configuration
├── data.tf        # AMI and SSM parameter sources
├── local.tf       # Local variables and tags
├── variables.tf   # Input variables
├── outputs.tf     # Bastion instance outputs
├── provider.tf    # AWS provider configuration
└── README.md      # This documentation
```

## 🛡️ Security Best Practices

### **✅ Implemented:**
- **Minimal Attack Surface**: Only SSH port open
- **Public Key Authentication**: No password access
- **Network Segmentation**: Clear separation of public/private
- **Centralized Access**: Single point of entry
- **Logging**: All SSH sessions can be logged

### **🔒 Additional Security (Optional):**
- **MFA**: Multi-factor authentication
- **Session Recording**: SSH session recording
- **IP Whitelisting**: Restrict source IP addresses
- **VPN Alternative**: Use VPN server instead for remote access

## 📊 Cost Optimization

- **Instance Size**: `t3.micro` provides sufficient capacity for SSH gateway
- **EBS Optimization**: Standard GP2 storage sufficient
- **Network**: Only standard public IP required

**The bastion host provides secure, cost-effective access to your RoboShop infrastructure!** 🚀
- `outputs.tf` - Output values
- `provider.tf` - Provider and Terraform configuration

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Update `terraform.tfvars` with your values:
   ```hcl
   project     = "roboshop"
   environment = "dev"
   instance_type = "t3.micro"
   key_name     = "your-key-pair-name"
   ```

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Dependencies

This configuration depends on:
- VPC resources (via SSM parameters)
- Security Group for bastion (via SSM parameter: `/${project}/${environment}/bastion_sg_id`)
- Public subnet IDs (via SSM parameter: `/${project}/${environment}/public_subnet_ids`)

## Outputs

- `bastion_instance_id` - EC2 instance ID
- `bastion_public_ip` - Public IP address for SSH access
- `bastion_private_ip` - Private IP address
- `bastion_public_dns` - Public DNS name
- `bastion_availability_zone` - AZ where instance is deployed

## SSH Access

Once deployed, you can SSH to the bastion host:

```bash
ssh -i your-key.pem ec2-user@<bastion_public_ip>
```

From the bastion host, you can then access private resources:

```bash
ssh -i your-key.pem ec2-user@<private_instance_ip>
```

## Security

- The bastion host is deployed in a public subnet but uses security groups to restrict access
- Only SSH (port 22) access should be allowed from trusted IP ranges
- Use key-based authentication only
- Consider using AWS Session Manager for additional security
