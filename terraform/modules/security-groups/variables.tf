variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created"
  type        = string
}

variable "project_name" {}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
}