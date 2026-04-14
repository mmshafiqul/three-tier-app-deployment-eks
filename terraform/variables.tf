variable "region" {
    type = string
    description = "The region to use for the VPC"
}

variable "profile" {
    type = string
    description = "The profile to use for the VPC"
}

variable "key_name" {
    type        = string
    description = "SSH key pair name"
    default     = "prod-key"
}

variable "algorithm" {
    type        = string
    description = "Key algorithm"
    default     = "RSA"
}

variable "rsa_bits" {
    type        = number
    description = "RSA key bits"
    default     = 2048
}

variable "instance_type" {
    type        = string
    description = "EC2 instance type"
    default     = "t3.medium"
}

variable "ami_id" {
    type        = string
    description = "AMI ID for EC2 instances"
    default     = "ami-019715e0d74f695be"
}

variable "ipv4_cidr_block" {
    type        = string
    description = "IPv4 CIDR block for VPC"
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
    type        = list(string)
    description = "CIDR blocks for public subnets"
    default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidr_blocks" {
    type        = list(string)
    description = "CIDR blocks for private subnets"
    default     = ["10.0.2.0/24"]
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
    default = {
        Name = "mmsuzon-vpc"
        Environment = "production"
    }
}

variable "kubernetes_version" {
    type        = string
    description = "Kubernetes version for EKS cluster"
    default     = "1.29"
}

variable "node_instance_type" {
    type        = string
    description = "EC2 instance type for EKS node group"
    default     = "t3.medium"
}

variable "desired_size" {
    type        = number
    description = "Desired number of worker nodes"
    default     = 2
}

variable "max_size" {
    type        = number
    description = "Maximum number of worker nodes"
    default     = 4
}

variable "min_size" {
    type        = number
    description = "Minimum number of worker nodes"
    default     = 2
}