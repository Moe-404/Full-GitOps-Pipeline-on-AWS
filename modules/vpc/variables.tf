variable "vpc_cidr" {}

variable "project_name" {}

variable "azs" {
  type        = list(string)
  description = "List of availability zones"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}



