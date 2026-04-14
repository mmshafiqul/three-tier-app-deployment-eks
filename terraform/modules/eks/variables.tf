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
  default     = 3
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "tags" {
  type        = map(string)
  description = "Tags for EKS resources"
}