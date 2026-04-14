output "public_route_table_id" {
    description = "ID of the public route table"
    value       = aws_route_table.public.id
}

output "private_route_table_id" {
    description = "ID of the private route table"
    value       = aws_route_table.private.id
}

output "public_route_table_association_ids" {
    description = "List of public route table association IDs"
    value       = aws_route_table_association.public[*].id
}

output "private_route_table_association_ids" {
    description = "List of private route table association IDs"
    value       = aws_route_table_association.private[*].id
}