variable "vpc_id" {
    type        = string
    description = "VPC ID for security group"
}

variable "public_subnet_id" {
    type        = string
    description = "Public subnet ID to place the bastion host"
}

variable "instance_type" {
    type        = string
    description = "EC2 instance type"
}

variable "ami_id" {
    type        = string
    description = "AMI ID for EC2 instance"
}

variable "key_name" {
    type        = string
    description = "SSH key pair name"
}

variable "tags" {
    type        = map(string)
    description = "Tags for bastion host"
}