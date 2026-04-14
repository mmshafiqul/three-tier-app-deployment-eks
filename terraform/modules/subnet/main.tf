# Public subnets
resource "aws_subnet" "public" {
    count                   = length(var.public_subnet_cidr_blocks)
    vpc_id                  = var.vpc_id
    cidr_block              = var.public_subnet_cidr_blocks[count.index]
    availability_zone       = length(var.availability_zones) > 0 ? var.availability_zones[count.index] : null
    
    map_public_ip_on_launch = true
    
    tags = merge(var.tags, {
        Name = "${var.tags["Name"]}-public-${count.index + 1}"
        Type = "public"
    })
}

# Private subnets
resource "aws_subnet" "private" {
    count             = length(var.private_subnet_cidr_blocks)
    vpc_id            = var.vpc_id
    cidr_block        = var.private_subnet_cidr_blocks[count.index]
    availability_zone = length(var.availability_zones) > 0 ? var.availability_zones[count.index] : null
    
    tags = merge(var.tags, {
        Name = "${var.tags["Name"]}-private-${count.index + 1}"
        Type = "private"
    })
}
