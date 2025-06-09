variable "region" {}
variable "account_id" {}
variable "secret_name" {
  description = "Name of the secret to be created"
  type        = string
  default     = "AWS-GradProject-Secret"
}
