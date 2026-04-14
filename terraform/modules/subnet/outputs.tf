output "public_subnet_ids" {
    description = "List of public subnet IDs"
    value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
    description = "List of private subnet IDs"
    value       = aws_subnet.private[*].id
}

output "public_subnet_cidr_blocks" {
    description = "List of public subnet CIDR blocks"
    value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidr_blocks" {
    description = "List of private subnet CIDR blocks"
    value       = aws_subnet.private[*].cidr_block
}

output "public_subnet_availability_zones" {
    description = "List of availability zones for public subnets"
    value       = aws_subnet.public[*].availability_zone
}

output "private_subnet_availability_zones" {
    description = "List of availability zones for private subnets"
    value       = aws_subnet.private[*].availability_zone
}