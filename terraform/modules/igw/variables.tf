variable "vpc_id" {
    type        = string
    description = "VPC ID to attach the Internet Gateway"
}

variable "tags" {
    type        = map(string)
    description = "Tags for Internet Gateway"
}