# VPC Outputs
output "vpc_id" {
    description = "The ID of the VPC"
    value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
    description = "The CIDR block of the VPC"
    value       = module.vpc.vpc_cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
    description = "List of public subnet IDs"
    value       = module.subnet.public_subnet_ids
}

output "private_subnet_ids" {
    description = "List of private subnet IDs"
    value       = module.subnet.private_subnet_ids
}

output "public_subnet_cidr_blocks" {
    description = "List of public subnet CIDR blocks"
    value       = module.subnet.public_subnet_cidr_blocks
}

output "private_subnet_cidr_blocks" {
    description = "List of private subnet CIDR blocks"
    value       = module.subnet.private_subnet_cidr_blocks
}

# IGW Outputs
output "internet_gateway_id" {
    description = "ID of the Internet Gateway"
    value       = module.igw.internet_gateway_id
}

# Route Table Outputs
output "public_route_table_id" {
    description = "ID of the public route table"
    value       = module.route_table.public_route_table_id
}

output "private_route_table_id" {
    description = "ID of the private route table"
    value       = module.route_table.private_route_table_id
}

# Bastion Host Outputs
output "bastion_instance_id" {
    description = "ID of the bastion host EC2 instance"
    value       = module.bastion.bastion_instance_id
}

output "bastion_public_ip" {
    description = "Public IP address of the bastion host"
    value       = module.bastion.bastion_public_ip
}

output "bastion_private_ip" {
    description = "Private IP address of the bastion host"
    value       = module.bastion.bastion_private_ip
}

output "bastion_security_group_id" {
    description = "Security group ID of the bastion host"
    value       = module.bastion.bastion_security_group_id
}

# Key Pair Outputs
output "key_name" {
    description = "The name of the AWS key pair"
    value       = module.key.key_name
}

output "private_key_path" {
    description = "Local path to the private key file"
    value       = module.key.private_key_path
}

# EKS Outputs
output "cluster_id" {
    description = "EKS cluster ID"
    value       = module.eks.cluster_id
}

output "cluster_arn" {
    description = "EKS cluster ARN"
    value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
    description = "EKS cluster endpoint"
    value       = module.eks.cluster_endpoint
}

output "cluster_name" {
    description = "EKS cluster name"
    value       = module.eks.cluster_name
}

output "cluster_security_group_id" {
    description = "EKS cluster security group ID"
    value       = module.eks.cluster_security_group_id
}

output "node_group_id" {
    description = "EKS node group ID"
    value       = module.eks.node_group_id
}