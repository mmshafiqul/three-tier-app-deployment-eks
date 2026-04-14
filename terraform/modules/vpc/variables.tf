variable "ipv4_cidr_block" {
    type        = string
    description = "IPv4 CIDR block for VPC"
}

variable "ipv6_cidr_block_enabled" {
    type        = bool
    description = "Enable IPv6 CIDR block"
    default     = false
}

variable "enable_dns_support" {
    type        = bool
    description = "Enable DNS support"
    default     = true
}

variable "enable_dns_hostnames" {
    type        = bool
    description = "Enable DNS hostnames"
    default     = true
}

variable "tags" {
    type        = map(string)
    description = "Tags for VPC"
}
