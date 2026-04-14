variable "vpc_id" {
    type        = string
    description = "VPC ID where route tables will be created"
}

variable "public_subnet_ids" {
    type        = list(string)
    description = "List of public subnet IDs to associate with public route table"
}

variable "private_subnet_ids" {
    type        = list(string)
    description = "List of private subnet IDs to associate with private route table"
}

variable "gateway_id" {
    type        = string
    description = "Internet Gateway ID for public route table"
}

variable "tags" {
    type        = map(string)
    description = "Tags for route tables"
}