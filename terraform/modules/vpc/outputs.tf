output "vpc_id" {
    description = "The ID of the VPC"
    value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
    description = "The CIDR block of the VPC"
    value       = aws_vpc.this.cidr_block
}

output "vpc_arn" {
    description = "The ARN of the VPC"
    value       = aws_vpc.this.arn
}

output "vpc_owner_id" {
    description = "The owner ID"
    value       = aws_vpc.this.owner_id
}

output "vpc_ipv6_cidr_block" {
    description = "The IPv6 CIDR block"
    value       = aws_vpc.this.ipv6_cidr_block
}