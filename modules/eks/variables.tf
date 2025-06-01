variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.28"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "instance_types" {
  description = "Instance types for worker nodes"
  type        = list(string)
}

variable "enable_public_endpoint" {
  description = "Enable public access to Kubernetes API"
  type        = bool
  default     = false
}

variable "key_pair_name" {
  description = "SSH key pair name for worker nodes"
  type        = string
  default     = ""
}
