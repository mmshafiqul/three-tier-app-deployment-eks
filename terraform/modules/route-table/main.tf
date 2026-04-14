# Public route table
resource "aws_route_table" "public" {
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = var.gateway_id
    }

    tags = merge(var.tags, {
        Name = "${var.tags["Name"]}-public-rt"
        Type = "public"
    })
}

# Private route table
resource "aws_route_table" "private" {
    vpc_id = var.vpc_id

    tags = merge(var.tags, {
        Name = "${var.tags["Name"]}-private-rt"
        Type = "private"
    })
}

# Public route table associations
resource "aws_route_table_association" "public" {
    count          = length(var.public_subnet_ids)
    subnet_id      = var.public_subnet_ids[count.index]
    route_table_id = aws_route_table.public.id
}

# Private route table associations
resource "aws_route_table_association" "private" {
    count          = length(var.private_subnet_ids)
    subnet_id      = var.private_subnet_ids[count.index]
    route_table_id = aws_route_table.private.id
}