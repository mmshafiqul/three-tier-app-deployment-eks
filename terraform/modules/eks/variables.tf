variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS cluster will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EKS cluster and node group"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS cluster"
}

variable "node_instance_type" {
  type        = string
  description = "EC2 instance type for EKS node group"
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
}

variable "tags" {
  type        = map(string)
  description = "Tags for EKS resources"
}