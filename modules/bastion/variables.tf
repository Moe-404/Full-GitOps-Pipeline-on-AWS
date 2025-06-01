variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "project_name" {}
variable "public_key" {
  description = "Public SSH key to be used for the bastion host"
  type        = string
}
variable "bastion_sg_id" {
  type = string
}