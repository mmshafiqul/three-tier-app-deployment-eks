output "internet_gateway_id" {
    description = "ID of the Internet Gateway"
    value       = aws_internet_gateway.this.id
}

output "internet_gateway_arn" {
    description = "ARN of the Internet Gateway"
    value       = aws_internet_gateway.this.arn
}

output "internet_gateway_owner_id" {
    description = "Owner ID of the Internet Gateway"
    value       = aws_internet_gateway.this.owner_id
}