resource "aws_vpc" "this" {
    cidr_block           = var.ipv4_cidr_block
    enable_dns_support   = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames

    tags = var.tags
}