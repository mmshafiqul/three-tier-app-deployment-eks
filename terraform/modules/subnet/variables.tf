variable "vpc_id" {
    type        = string
    description = "VPC ID where subnets will be created"
}

variable "public_subnet_cidr_blocks" {
    type        = list(string)
    description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidr_blocks" {
    type        = list(string)
    description = "CIDR blocks for private subnets"
}

variable "availability_zones" {
    type        = list(string)
    description = "Availability zones for subnets"
    default     = []
}

variable "tags" {
    type        = map(string)
    description = "Tags for subnets"
}
